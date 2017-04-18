//
//  ViewController.swift
//  translator
//
//  Created by Allen He on 4/18/17.
//  Copyright © 2017 Allen He. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    //0.0 to 1.0
    private var speechRate = AVSpeechUtteranceDefaultSpeechRate
    
    //0.5 to 2.0, 1.0 is default
    private var pitchMultiplier: Float = 1.0
    
    //0.0 to 1.0, 1.0 is default
    private var volume: Float = 1.0
    
    @IBAction func speakClicked(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speakButton.isEnabled = false
            speakButton.setTitle("Start Recording", for: .normal)
            statusLabel.text = ""
        } else {
            startRecording()
            speakButton.setTitle("Stop Recording", for: .normal)
            statusLabel.text = "Listening..."
        }
//        speakTranslated()
    }
    
    func speakTranslated(){
        let speechUtterance = AVSpeechUtterance(string: textView.text)
        speechUtterance.rate = speechRate
        speechUtterance.pitchMultiplier = pitchMultiplier
        speechUtterance.volume = volume
        speechSynthesizer.speak(speechUtterance)
    }
    
    func startRecording(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.speakButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization{(authStatus) in
            switch authStatus{
            case .authorized:
                break
            case .denied, .restricted, .notDetermined:
                self.speakButton.isEnabled = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            speakButton.isEnabled = true
        } else {
            speakButton.isEnabled = false
        }
    }

}

