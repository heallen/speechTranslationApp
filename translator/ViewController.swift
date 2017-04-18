//
//  ViewController.swift
//  translator
//
//  Created by Allen He on 4/18/17.
//  Copyright © 2017 Allen He. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    //0.0 to 1.0
    var speechRate = AVSpeechUtteranceDefaultSpeechRate
    
    //0.5 to 2.0, 1.0 is default
    var pitchMultiplier: Float = 1.0
    
    //0.0 to 1.0, 1.0 is default
    var volume: Float = 1.0
    
    @IBAction func speakClicked(_ sender: Any) {
        let speechUtterance = AVSpeechUtterance(string: "Hello Allen, Good Morning")
        speechUtterance.rate = speechRate
        speechUtterance.pitchMultiplier = pitchMultiplier
        speechUtterance.volume = volume
        speechSynthesizer.speak(speechUtterance)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

