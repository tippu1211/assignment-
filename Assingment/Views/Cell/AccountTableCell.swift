//
//  AccountTableCell.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation
import UIKit
import Speech

class AccountTableCell: UITableViewCell {
    
    
    @IBOutlet weak var accountIdLbl: UILabel!
    
    @IBOutlet weak var accountNameLbl: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    var onAlternateNameChanged: ((String) -> Void)?
    var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var audioEngine = AVAudioEngine()
    var speechRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var localLanguageCode = Locale.current.identifier
    var speechTimer: Timer?
    var noInputTimeOut: Int?
    var inputNode: AVAudioInputNode?
    var isListening: Bool?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        onAlternateNameChanged?(textField.text ?? "")
    }
    
    @IBAction func micButtonAction(_ sender: Any) {
        checkSpeechRecognizationPermission { granted in
            if granted {
                self.startRecognizeTextUsingSpeechFramework(languageCode: self.localLanguageCode) { resultText, isFinal, error in
                    if isFinal{
                        self.userNameTextField.text = resultText
                    }
                }
            }
        }
    }
    
    func checkSpeechRecognizationPermission(completionHandler: @escaping(Bool) -> Void) {
    
        SFSpeechRecognizer.requestAuthorization{ status in
            switch status {
            case .notDetermined:
                print("Not Determined")
                completionHandler(false)
                break
            case .denied:
                print("Denied")
                completionHandler(false)
                break
            case .restricted:
                print("Restricted")
                completionHandler(false)
                break
            case .authorized:
                print("Authorized")
                completionHandler(true)
                break
            @unknown default:
                completionHandler(false)
                break
            }

        }
    }
    
    func startRecognizeTextUsingSpeechFramework(languageCode: String, completionHandler: @escaping (String?, Bool, Error?) -> Void) {

        audioEngine = AVAudioEngine()

        
        if recognitionTask != nil {
            recognitionTask = nil
        }

        speechRequest = SFSpeechAudioBufferRecognitionRequest()

        inputNode = audioEngine.inputNode

        if speechRequest == nil {
            print("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        if inputNode == nil {
            print("Unable to create an inputNode object")
        }

        speechRequest?.shouldReportPartialResults = true

        var locale:Locale? = Locale(identifier: languageCode)
        if (locale == nil) {
            locale = Locale(identifier: localLanguageCode)
        }

        if let speechLocale = locale {
            speechRecognizer = SFSpeechRecognizer(locale: speechLocale)
        } else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey: "Input language '\(languageCode)' is not supported"])
            completionHandler(nil, false, error)
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: speechRequest ?? SFSpeechAudioBufferRecognitionRequest()) { result, error in

            if error == nil {

                let translatedString = result?.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)

                if result?.isFinal ?? true {

                    print("Final Speech RESULT:\(translatedString ?? "")")

                } else {

                    print("Partial Speech RESULT:\(translatedString ?? "")")
                    self.createSpeechTimer(0.55)
                }

                completionHandler(translatedString, result?.isFinal ?? false, error)

            } else {

                self.speechTimerEnds()
                completionHandler(nil, false, error)
            }
        }

        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: inputNode?.outputFormat(forBus: 0)) { buffer, when in
            self.speechRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            print("Audio listening started...")
            createSpeechTimer(Float(noInputTimeOut ?? 10))
        } catch {
            print("Error \(error)")
        }
    }
    
    func createSpeechTimer(_ timerValue: Float?) {

        DispatchQueue.main.async {

            if (self.speechTimer != nil) {
                self.speechTimer?.invalidate()
                self.speechTimer = nil
                print("Speech Timer Invalidated")
            }

            if (self.speechRequest != nil) {
                print("Speech Timer Started : interval : \(String(describing: timerValue))")
                self.speechTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timerValue ?? 0), target: self, selector: #selector(self.speechTimerEnds), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func speechTimerEnds() {

        if (speechTimer != nil) {
            speechTimer?.invalidate()
            speechTimer = nil
            endRecognizer()
            print("Speech Timer Ends")
        }

    }
    
    func endRecognizer() {

        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        speechRequest?.endAudio()
        isListening = false

    }
    
    
    
}
