//
//  DetailViewController.swift
//  CoreMLDemos
//
//  Created by Jon Manning on 4/7/18.
//  Copyright © 2018 Secret Lab. All rights reserved.
//

import UIKit

/// Represents a simple sentiment: positive, or negative.
enum Sentiment : String {
    
    case positive
    case negative
    
}

// Converts an optional Sentiment into an emoji representation.

// We extend Optionals that might include a Sentiment value.
extension Optional where Wrapped == Sentiment {
    
    /// Returns an emoji representation of the value: a smiling face if .positive, a frowning face if .negative, and an indecisive face if nil.
    var emoji : String {
        switch self {
            
        case .some(.positive):
            return "🙂"
        case .some(.negative):
            return "🙁"
        case .none:
            return "🤔"
        }
    }
}

/// A wrapper class that converts strings into sentiments.
class SentimentProcessor {
    
    // BEGIN sentiment_variables
    // The CoreML model we'll use to perform the classifications
    let sentimentModel = SentimentClassifier()
    
    // A tagger that can break up text into a series of words
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
    // END sentiment_variables
    
    // BEGIN sentiment_bag_of_words
    // Given a string, returns a dictionary containing the word count for each
    // unique word.
    func bagOfWords(from text: String) -> [String: Double] {
        
        // The dictionary we'll send back
        var result : [String: Double] = [:]
        
        // NSLinguisticTagger hasn't been updated to use Swift's range types,
        // so we use the older NSRange type.
        
        // Create an NSRange that refers to the entire length of the input.
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Create an option set that indicates to the tagger that we want
        // to skip all punctuation and whitespace.
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        // Provide the text to the tagger.
        tagger.string = text
        
        // Loop over every token in the sentence.
        tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) {
            _, tokenRange, _ in
            
            // This block will be called for each token (i.e. word) in the
            // text.
            
            // Get the region of the input string that contains this token
            let word = (text as NSString).substring(with: tokenRange)
            
            // Increment the number of times we've seen this word.
            result[word, default: 0] += 1
        }
        
        // Return the summed word counts.
        return result
    }
    // END sentiment_bag_of_words
    
    /// Produces a Sentiment from a given string, corresponding to its predicted
    /// tone, and the probability
    func sentiment(for text: String) -> (Sentiment?, Double?) {
        
        // BEGIN sentiment_predict
        // Get the bag of words from the text
        let bagOfWords = self.bagOfWords(from: text)
        
        if bagOfWords.count == 0 {
            // No words. Nothing to classify.
            return (nil, nil)
        }
        
        do {
            // Perform the prediction using this bag of words
            let prediction = try sentimentModel.prediction(text: bagOfWords)
            
            // Get the predicted class
            let sentimentClass = prediction.sentimentClass
            
            // Get the probability of the predicted class
            let sentimentProbability = prediction.sentimentClassProbability[sentimentClass] ?? 0
            
            // Indicate this sentiment
            return (Sentiment(rawValue: prediction.sentimentClass), sentimentProbability)
            
        } catch {
            return (nil, nil)
        }
        // END sentiment_predict
    }
}

class SentimentAnalysisViewController: UIViewController {
    
    let processor = SentimentProcessor()

    // The views that display the predictions
    @IBOutlet weak var sentimentResultLabel: UILabel!
    @IBOutlet weak var sentimentProbabilityLabel: UILabel!
    
    // The text view that the user enters their text in
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        
        // Clear the text view and display the keyboard
        textView.text = ""
        textView.becomeFirstResponder()
        
        updateResult()
    }
    
    func updateResult() {
        
        let sentiment : Sentiment?
        let probability : Double?
        
        // If less than 3 characters are entered, assume not enough data
        if textView.text.count < 3 {
            sentiment = nil
            probability = 0
        } else {
            (sentiment, probability) = processor.sentiment(for: textView.text)
        }
        
        sentimentResultLabel.text = sentiment.emoji
        
        let probabilityString : String
        
        if let probability = probability {
            probabilityString = "\(Int(probability * 100))%"
        } else {
            probabilityString = "--"
        }
        
        sentimentProbabilityLabel.text = probabilityString
        
    }
}

extension SentimentAnalysisViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateResult()
    }
    
}

