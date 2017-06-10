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


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var transcriptionTextField: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var playLbl: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        
    }
    
    
    func requestSpeechAuth() {
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                if let path = Bundle.main.url(forResource: "JML", withExtension: "m4a") {
                    do {
                        let sound = try AVAudioPlayer(contentsOf: path)
                        self.audioPlayer = sound
                        self.audioPlayer.delegate = self
                        sound.play()
                    } catch {
                        print("Error!")
                    }
                    
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: path)
//                    print("about to run recognizer")
                    recognizer?.recognitionTask(with: request) { (result, error) in
                        if let error = error {
                            print("threre was an error \(error)")
                        } else {
                            self.transcriptionTextField.text = result?.bestTranscription.formattedString
//                            print(result?.bestTranscription.formattedString)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        playLbl.text = "TRANSCRIBING AUDIO..."
        activitySpinner.isHidden = false
        activitySpinner.startAnimating()
        requestSpeechAuth()
        
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
        playLbl.text = "READY TO TRANSCRIBE"
    }
}

