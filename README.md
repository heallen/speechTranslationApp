# Easy Translate

## Description
This an iOS app that is designed to enable conversation between two different languages using primarily speech-to-speech translation. 

## Usage
![alt text](https://github.com/heallen/speechTranslationApp/blob/master/images/mainScreen.PNG)
![alt text](https://github.com/heallen/speechTranslationApp/blob/master/images/translated.PNG)
The first user selects a language to speak from the left picker view (input), and a language to translate to from the right picker view (output).
He hits the record button to start recording, and the detected speech will appear as text in the text view. The first user will hit stop recording when he is done.
If he is not satisfied with the detected speech, he can manually change the text in the text view. Once he is satisfied, he can press the "Translate and Speak" button, and the translated text will be displayed the text view, and spoken in the output language.
He then clicks the "Swap Languages" button, which will swap the selected input and output languages, and hands the phone off to the other user to talk back in a similar manner.

To setup the app, you will need to download the files and put in your own Microsoft Cognitive Services API key in ViewController.swift.

## Technologies Used
The app is written with Swift 3. It uses Apple's Speech API to perform speech to text, Microsoft's text-to-text translation API to perform the actual translation, and uses Apple's SpeechSynthesizer to speak out the translated text. Web requests are made with Alamofire. 

## Motivation
This app was built for an introductory course to iOS development at the University of Pennsylvania.
