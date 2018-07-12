#!/usr/bin/env python

import sys
import os
import turicreate as tc

# The location of the input data
DATA_LOCAL = "datasets/sentiment_sentences/amazon_reviews.tsv"

# Check that the file is there
if not os.path.exists(DATA_LOCAL):
    print("%s does not exist.", DATA_LOCAL)
    sys.exit(1)

# Read the data
reviews = tc.SFrame.read_csv(DATA_LOCAL, delimiter='\t', header=True)

# Select the specific columns we want
reviews = reviews['review_body', 'star_rating']

# Label each review based on star rating; >4 stars is positive, <4 stars is negative
reviews['sentimentClass'] = reviews['star_rating'].apply(lambda rating: 'positive' if rating >= 4 else 'negative')

# Remove the star rating column; we don't need it anymore
reviews.remove_column('star_rating')

# Split the reviews into positive and negative
positive = reviews[reviews['sentimentClass'] == 'positive']
negative = reviews[reviews['sentimentClass'] == 'negative']

# We want an even number of positive and negative reviews, so pick the list
# that has the shorter amount...
review_count = min(len(positive), len(negative))

# And trim both lists to that count
positive = positive.head(review_count)
negative = negative.head(review_count)

# Now combine them back together
reviews = positive.append(negative)

# Save the SFrame for later use
MODEL_PATH = "amazon_reviews.sframe"
reviews.save(MODEL_PATH)

# Create the model! We're telling it to look at the 'review_body' column as its input,
# and the 'sentimentClass' column as the label.
model = tc.sentence_classifier.create(reviews, 'sentimentClass', features=['review_body'])

# Evaluate this model
evaluation = model.evaluate(reviews)

# Print the evaluation
print(evaluation)

# Export the model into a form that Core ML can use
COREML_MODEL_PATH = "SentimentClassifier.mlmodel"
model.export_coreml(COREML_MODEL_PATH)

print("Created model at {}".format(COREML_MODEL_PATH))