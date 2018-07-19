#!/usr/bin/env python

# Some standard libraries
import argparse
import csv
import os
import sys
import math
import zlib 

# For data downloads
import requests

# Turi Create
import turicreate as tc

# For prompting the user
from readchar import readchar

# For showing a nice progress bar
from tqdm import tqdm

# The location of the license the user must agree to before downloading the data
LICENSE_URL = "https://s3.amazonaws.com/amazon-reviews-pds/LICENSE.txt"

# The location of the data
DATA_URL = "https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_us_Major_Appliances_v1_00.tsv.gz"

# The path to where we'll save the data
DATA_LOCAL = "datasets/sentiment_sentences/amazon_reviews.tsv"

def download_data(args):
    """Downloads the dataset from the internet. The user must read and agree
    to the dataset's license."""

    # Download and present the license
    print("Loading license...")

    license = requests.get(LICENSE_URL).text

    print(license)
    print()
    print("Do you accept the license? [y/n]")
    if readchar() != "y":
        print("Exiting.")
        sys.exit(1)

    # Download and decompress the data
    print("Downloading {}...".format(DATA_URL))
    
    data = requests.get(DATA_URL, stream=True)

    total_size = int(data.headers.get('content-length', 0)); 
    block_size = 1024
    wrote = 0 

    # Create the directory we'll store the data in
    os.makedirs(os.path.dirname(DATA_LOCAL), exist_ok=True)

    decompress = zlib.decompressobj(32 + zlib.MAX_WBITS)

    # Download and decompress the data
    with open(DATA_LOCAL, 'wb') as f:
        for data in tqdm(data.iter_content(block_size), total=math.ceil(total_size//block_size) , unit='KB', unit_scale=True):
            wrote = wrote  + len(data)

            decompressed = decompress.decompress(data)

            f.write(decompressed)
    
    if total_size != 0 and wrote != total_size:
        print("Failed to download data.")  
        sys.exit(1)
    
    print("Downloaded data to {}".format(DATA_LOCAL))

def process_data(args):
    """Loads the raw data in tab-separated values form, and converts it into
    an SFrame."""
    
    out_path = args.output

    out_list = []

    in_path = DATA_LOCAL

    if not os.path.exists(in_path):
        print("%s does not exist. Download it first, using the download-data command (see --help)", in_path)
        sys.exit(1)

    # We need to increase the maximum per-field limit in order to fit the review text
    csv.field_size_limit(sys.maxsize)

    # An SFrameBuilder allows you to construct an SFrame, row-by-row.
    builder = tc.SFrameBuilder(
        [str,str],  # the types of the columns
        ['text', 'sentimentClass'] # the names of the columns
    )

    # Open the input file
    with open(in_path, "r") as in_file:

        # Start reading the file; each row will be a dictionary
        in_tsv = csv.DictReader(in_file, delimiter='\t')

        # Keep track of how many positive and negative reviews we have
        positive_count = 0
        negative_count = 0

        for row in in_tsv:
            
            text = row['review_body'].strip()
            score = int(row['star_rating'].strip())
            
            if score >= 4:
                # This is a positive (4+ star) review.
                textClass = 'positive'

                # Do we already have more positive reviews than negative?
                if positive_count > negative_count:
                    # Then skip it
                    continue

                positive_count += 1
            else:
                # This is a negative (3 or fewer star) review.
                textClass = 'negative'

                # Do we already have more negative reviews than positive?
                if negative_count > positive_count:
                    # Then skip it
                    continue

                negative_count += 1

            # Add this row to the frame
            builder.append([text,textClass])

    print("Processed {} positive and {} negative reviews".format(positive_count, negative_count))

    # Produce a finalised SFrame from the builder
    sf = builder.close()

    # Save it
    sf.save(out_path)

    # Print a snippet of the data
    sf.head(n=20).print_rows(max_column_width=60)

def create_model(args):
    """Loads the processed data, and creates a model that classifies text."""

    in_path = args.input
    out_path = args.output

    if not os.path.exists(in_path):
        print("%s does not exist. Process the data into an SFrame using the process-data command first (see --help)", in_path)
        sys.exit(1)

    print("Loading data from {}".format(in_path))

    # Load the data
    data = tc.SFrame(in_path)

    # Print a snippet of the data
    print(data.head())

    model = tc.sentence_classifier.create(data, 'sentimentClass', features=['text'])

    # Evaluate this model
    evaluation = model.evaluate(data)

    # Print the evaluation
    print(evaluation)

    # Export the model into a form that Core ML can use
    model.export_coreml(out_path)

    print("Created model at {}".format(out_path))


def main():
    """Parses and handles command-line arguments."""
    
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    # Set up a parser for the "download-data" command.
    parser_download_data = subparsers.add_parser('download-data')
    assert isinstance(parser_download_data, argparse.ArgumentParser)
    parser_download_data.set_defaults(func=download_data)

    # Set up a parser for the "process-data" command.
    parser_process_data = subparsers.add_parser('process-data')
    assert isinstance(parser_process_data, argparse.ArgumentParser)
    parser_process_data.add_argument("output", type=str)
    parser_process_data.set_defaults(func=process_data)

    # Set up a parser for the "create-model" command.
    parser_create_model = subparsers.add_parser('create-model')
    assert isinstance(parser_create_model, argparse.ArgumentParser)
    parser_create_model.add_argument("input", type=str)
    parser_create_model.add_argument("output", type=str)
    parser_create_model.set_defaults(func=create_model)

    args = parser.parse_args()

    if not "func" in args:
        parser.print_help()
        return

    args.func(args)

if __name__ == '__main__':
    main()

    
    