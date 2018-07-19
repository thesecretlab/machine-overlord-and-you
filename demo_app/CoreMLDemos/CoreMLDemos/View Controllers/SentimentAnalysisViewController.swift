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
    
    // SNIP: sentiment_variables
    
    // SNIP: sentiment_bag_of_words
    
    /// Produces a Sentiment from a given string, corresponding to its predicted
    /// tone, and the probability
    func sentiment(for text: String) -> (Sentiment?, Double?) {
        
        // SNIP: sentiment_predict
        
        return (nil, nil)
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

