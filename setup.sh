#!/bin/bash

set -e

echo "This script will download a number of datasets and models. It will download about 2GB."
echo 
echo "Additionally, you will be prompted to read and accept the license for the Amazon reviews dataset."
echo
echo "Press any key to continue."
read -n 1 -r
echo

# Download and display the license.
AMAZON_LICENSE="https://s3.amazonaws.com/amazon-reviews-pds/LICENSE.txt"

curl $AMAZON_LICENSE

echo 

# Prompt the user to agree to the license. Exit if they decline.
read -p "Do you accept this license? (y/n) " -n 1 -r
echo    
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

# Create the folders that will store the datasets and models
mkdir -p datasets
mkdir -p models

echo "Opening the link to the Cats and Dogs dataset - please unzip into the datasets/cats_dogs directory"

open "https://www.microsoft.com/en-us/download/details.aspx?id=54765"

echo "Downloading Amazon reviews"

curl https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_us_Major_Appliances_v1_00.tsv.gz | gunzip > datasets/sentiment_sentences/amazon_reviews.tsv

echo "Downloading MNIST model"

pushd models
curl -O https://s3-us-west-2.amazonaws.com/coreml-models/MNIST.mlmodel
popd

echo "Downloading style transfer models"

pushd models
# We rename these to remove the hyphens from the names, which causes problems in Xcode
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Udnie.mlmodel -o FNSUdnie.mlmodel
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Candy.mlmodel -o FNSCandy.mlmodel
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Feathers.mlmodel -o FNSFeathers.mlmodel
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-La-Muse.mlmodel -o FNSLaMuse.mlmodel
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Mosaic.mlmodel -o FNSMosaic.mlmodel
curl https://s3-us-west-2.amazonaws.com/coreml-models/FNS-The-Scream.mlmodel -o FNSTheScream.mlmodel
popd

echo "Downloading image classification models"

pushd models
curl -O https://docs-assets.developer.apple.com/coreml/models/VGG16.mlmodel
popd models