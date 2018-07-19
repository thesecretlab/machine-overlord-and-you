#!/usr/bin/env python

import turicreate as tc

DATA_PATH = "datasets/cats_dogs/PetImages"

print("Loading data...")

# Load the images into an SFrame; also include a column that contains the path
# Not all images are valid, but that's fine, since we have so many of them
data = tc.image_analysis.load_images(DATA_PATH, with_path=True)

# Create a label column from the path
data['label'] = data['path'].apply(lambda path: 'dog' if '/Dog' in path else 'cat')


COUNT_PER_CLASS=50

print("Limiting to {} images per class".format(COUNT_PER_CLASS))

cats = data[data['label'] == 'cat'].head(COUNT_PER_CLASS)
dogs = data[data['label'] == 'dog'].head(COUNT_PER_CLASS)

data = cats.append(dogs)

print("Creating model...")

# Create the model - it will automatically detect the image column, but we must provide
# the column that contains the labels
model = tc.image_classifier.create(data, target='label')

# Save the trained model for later use in Turi Create, if we want it
model.save("CatDogClassifier.model")

# Export the model for use in Core ML
model.export_coreml('CatDogClassifier.mlmodel')
