//
//  ViewController.swift
//  Scribe
//
//  Created by J. M. Lowe on 6/9/17.
//  Copyright © 2017 JMLeaux LLC. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var transcriptionTextField: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var playLbl: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        
    }

    
    func requestSpeechAuth() -> String {
        
        var speechText: String = ""
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                if let path = Bundle.main.url(forResource: "test", withExtension: "m4a") {
                    do {
                        let sound = try AVAudioPlayer(contentsOf: path)
                        self.audioPlayer = sound
                        sound.play()
                    } catch {
                        print("Error!")
                    }
                    
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: path)
                    recognizer?.recognitionTask(with: request) { (result, error) in
                        if let error = error {
                            print("There was an error: \(error)")
                        } else {
//                            print(result?.bestTranscription.formattedString)
                            if result?.bestTranscription.formattedString != nil {
                                speechText = (result?.bestTranscription.formattedString)!
                            } else {
                                speechText = ""
                            }
                        }
                    }
                }
            }
        }
        return(speechText)
    }
    

    @IBAction func playButtonPressed(_ sender: Any) {
        playLbl.text = "TRANSCRIBING AUDIO..."
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
        transcriptionTextField.text = requestSpeechAuth()
        playLbl.text = "PRESS TO TRANSCRIBE"
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
        
    }

}

