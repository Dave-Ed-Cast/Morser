//
//  EncodeIntentHandler.swift
//  Morser
//
//  Created by Davide Castaldi on 02/06/24.
//

import Foundation
import Intents

class EncodeIntentHandler: NSObject, EncodeIntentHandling {
    
    /// This is the function that gives the output of the siri command
    /// - Parameter intent: the intent we are using
    /// - Returns: returns the phrase of depending on the outcome
    func resolvePhrase(for intent: EncodeIntent) async -> INStringResolutionResult {
        
        if let phrase = intent.phrase, !phrase.isEmpty {
            return .success(with: phrase)
        } else {
            return .needsValue()
        }
    }
    
    /// This is just for stubs, so for now it returns nothing in particular
    /// - Parameter intent: the intent we are using
    /// - Returns: returns an empty INObjectCollection
    func providePhraseOptionsCollection(for intent: EncodeIntent) async throws -> INObjectCollection<NSString> {
            // Return an empty collection for now, or populate it with relevant options if you have any
            let options: [NSString] = []
            return INObjectCollection(items: options)
        }
    
    
    /// This is the core function of the intent handler
    /// - Parameters:
    ///   - intent: The intent we are using
    ///   - completion: What happens if it's completed
    func handle(intent: EncodeIntent, completion: @escaping (EncodeIntentResponse) -> Void) {

        //just tell that it failed if you cant fetch the phrase
        guard let phrase = intent.phrase else {

            let response = EncodeIntentResponse(code: .failure, userActivity: nil)
            completion(response)
            return
        }
        
        //read the text and morse it
        VibrationEngine.shared.readMorseCode(morseCode: phrase)
        
        //create the response for siri
        let response = EncodeIntentResponse.success(textToMorse: phrase)
        
        //this is the result
        completion(response)
    }
}
