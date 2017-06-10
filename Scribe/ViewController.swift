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
    @IBOutlet weak var transcribeButton: CircleButton!
    
    var audioPlayer: AVAudioPlayer!
    private let speechrecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        
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
        
        recognitionTask = speechrecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = true
            
            if let result = result {
                self.transcriptionTextField.text = result.bestTranscription.formattedString
//                print(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil {
                print("ERROR: the code is \n\(error!)")
            }
            
            if isFinal {
                
                print("finished - isFinal is \(isFinal)")
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.playLbl.text = "Ready to record..."
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        self.transcriptionTextField.text = "I'm ready for you to dictate..."
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            transcribeButton.isEnabled = true
            activitySpinner.isHidden = true
            playLbl.text = "Press to start dictation"
        } else {
            transcribeButton.isEnabled = false
            playLbl.text = "Recognition not available"
        }
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if audioEngine.isRunning {
            print("audioEngine is running...")
            audioEngine.stop()
            recognitionRequest?.endAudio()
            activitySpinner.stopAnimating()
            activitySpinner.isHidden = true
            playLbl.text = "Press to record and transcribe..."
        } else {
            print("audioEngine not running, trying startRecording...")
            try! startRecording()
            playLbl.text = "TRANSCRIBING...press to stop..."
        }
    }
}

