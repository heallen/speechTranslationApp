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
import Alamofire
import Foundation

class ViewController: UIViewController, SFSpeechRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var authToken: String!
    private var languages: [String]!
    private var languageCodes: [String]!
    private var languageCodesRegional: [String]!
    private var recordingLanguageCode: String = "en-US"
    private var speakingLanguageCode: String = "en-US"
    private var sourceLanguageCode: String = "en"
    private var targetLanguageCode: String = "en"
    private var selectedSourceIndex: Int = 0
    private var selectedTargetIndex: Int = 0
    weak var timer: Timer?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    //0.0 to 1.0
    private var speechRate = AVSpeechUtteranceDefaultSpeechRate
    
    //0.5 to 2.0, 1.0 is default
    private var pitchMultiplier: Float = 1.0
    
    //0.0 to 1.0, 1.0 is default
    private var volume: Float = 1.0
    
    @IBAction func recordClicked(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speakButton.isEnabled = false
            speakButton.setTitle("Record", for: .normal)
            statusLabel.text = " "
            audioEngine.inputNode?.removeTap(onBus: 0)
        } else {
            startRecording()
            speakButton.setTitle("Stop Recording", for: .normal)
            statusLabel.text = "Listening..."
        }
    }
    
    @IBAction func translateClicked(_ sender: Any) {
        let inputText = textView.text!
        let appid = "Bearer " + authToken
        let parameters: Parameters = [
            "appid": appid,
            "text": inputText,
            "from": sourceLanguageCode,
            "to": targetLanguageCode
        ]
        Alamofire.request("https://api.microsofttranslator.com/V2/Http.svc/Translate", method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                let startIndex = utf8Text.index(utf8Text.startIndex, offsetBy: "<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">".characters.count)
                let endIndex = utf8Text.index(utf8Text.endIndex, offsetBy: -"</string>".characters.count)
                let translatedText = utf8Text.substring(with: startIndex..<endIndex)
                self.textView.text = translatedText
                self.speakTranslated()
            }
        }
    }
    
    func getAuthToken(){
        let key = "6d25455a838541f9ba749fbc487cee1b"
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": key
        ]
        Alamofire.request("https://api.cognitive.microsoft.com/sts/v1.0/issueToken", method: .post, headers: headers).responseJSON { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                self.authToken = utf8Text
            }
        }
    }
    
    func speakTranslated(){
        let speechUtterance = AVSpeechUtterance(string: textView.text)
        speechUtterance.rate = speechRate
        speechUtterance.pitchMultiplier = pitchMultiplier
        speechUtterance.volume = volume
        speechUtterance.voice = AVSpeechSynthesisVoice(language: speakingLanguageCode)
        print("translation spoken")
        speechSynthesizer.speak(speechUtterance)
    }
    
    func startRecording(){
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
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
                self.recognitionRequest?.endAudio()
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

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            speakButton.isEnabled = true
        } else {
            speakButton.isEnabled = false
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            selectedSourceIndex = row
            sourceLanguageCode = languageCodes[row]
            speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: languageCodesRegional[row]))
            speechRecognizer?.delegate = self
        } else{
            selectedTargetIndex = row
            targetLanguageCode = languageCodes[row]
            speakingLanguageCode = languageCodesRegional[row]
        }
    }
    
    @IBAction func swapClicked(_ sender: Any) {
        let originalTargetIndex = selectedTargetIndex
        let originalSourceIndex = selectedSourceIndex
        pickerView.selectRow(selectedTargetIndex, inComponent: 0, animated: true)
        pickerView.selectRow(selectedSourceIndex, inComponent: 1, animated: true)
        pickerView(pickerView, didSelectRow: originalTargetIndex, inComponent: 0)
        pickerView(pickerView, didSelectRow: originalSourceIndex, inComponent: 1)
        selectedTargetIndex = originalSourceIndex
        selectedSourceIndex = originalTargetIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        textView.returnKeyType = .done
        textView.delegate = self
        languages = LanguageData.getLanguages()
        languageCodes = LanguageData.getLanguageCodes()
        languageCodesRegional = LanguageData.getLanguageCodesRegional()
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
        speechRecognizer?.delegate = self
        getAuthToken()
//        timer = Timer.scheduledTimer(withTimeInterval: 500.0, repeats: true) {[weak self] _ in
//            self!.getAuthToken()
//        }
        timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 500, target: self, selector: #selector(self.getAuthToken), userInfo: nil, repeats: true)
        SFSpeechRecognizer.requestAuthorization{(authStatus) in
            switch authStatus{
            case .authorized:
                break
            case .denied, .restricted, .notDetermined:
                self.speakButton.isEnabled = false
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

