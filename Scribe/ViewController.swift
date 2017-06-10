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


class ViewController: UIViewController, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate  {
    
    @IBOutlet weak var transcriptionTextField: UITextView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var playLbl: UILabel!
    
    var audioPlayer: AVAudioPlayer!
    private let speechrecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
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
    
    func requestSpeechAuthFromMic() {       // audio source is microphone!
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
//                if let path = Bundle.main.url(forResource: "JML", withExtension: "m4a") {
//                    do {
//                        let sound = try AVAudioPlayer(contentsOf: path)
//                        self.audioPlayer = sound
//                        self.audioPlayer.delegate = self
//                        sound.play()
//                    } catch {
//                        print("Error!")
//                    }
                
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true
//                let recordingFormat = inputNode.outputFormat(forBus: 0)
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
    
    func startRecording() throws {
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: . notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node.") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a speech recognition object")}
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechrecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = true
            
            if let result = result {
                self.transcriptionTextField.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.playLbl.text = "Ready to record..."
            }
        }
        
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
            playLbl.text = "Press to record and transcribe..."
        } else {
            try! startRecording()
            playLbl.text = "TRANSCRIBING...press to stop..."
        }
        
//        playLbl.text = "TRANSCRIBING AUDIO..."
//        activitySpinner.isHidden = false
//        activitySpinner.startAnimating()
//        requestSpeechAuth()
        
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
        playLbl.text = "READY TO TRANSCRIBE"
    }
}

