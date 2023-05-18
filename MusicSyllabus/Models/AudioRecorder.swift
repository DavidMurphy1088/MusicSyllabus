import SwiftUI
import CoreData
import AVFoundation

class AudioRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, ObservableObject {
    static let shared = AudioRecorder()
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename:URL?
    @Published var status:String = ""
    
    func setStatus(_ msg:String) {
        DispatchQueue.main.async {
            self.status = msg
        }
    }
    
    func startRecording()  {
        recordingSession = AVAudioSession.sharedInstance()
        audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        AppDelegate.startAVAudioSession(category: .record)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            Logger.logger.log(self, "Recording started - isRecording?: \(audioRecorder.isRecording)")
            if audioRecorder.isRecording {
                setStatus("Recording started")
            }
            else {
                setStatus("Recording not started")
            }
        } catch let error {
            Logger.logger.reportError(self, "Recording did not start", error)
            stopRecording()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //print("NOTIFY::did finish recording, success:", flag)
        //finishRecording(success: flag)
    }

    func stopRecording() {
        print("--------------Trying to stop recorder", audioRecorder != nil)
        if audioRecorder == nil {
            Logger.logger.reportError(self, "audioRecorder is nil at stop")
        }
        else {
            Logger.logger.log(self, "Recording ended - wasRecording? -\(audioRecorder.isRecording) secs:\(String(format: "%.1f", audioRecorder.currentTime))")
            setStatus("Recorded time \(String(format: "%.1f", audioRecorder.currentTime)) seconds")
            //print(audioRecorder.currentTime)
            audioRecorder.stop()
            do {
//                try recordingSession.setCategory(.playback, mode: .default)
//                try recordingSession.setActive(true) //DONT DO
//                try recordingSession.setCategory(.playback, mode: .default)
            }
            catch let error {
                Logger.logger.reportError(self, "Recording ended with error", error)
            }
            AppDelegate.startAVAudioSession(category: .playback)
            //audioRecorder = nil
            //recordingSession = nil
        }
    }

    func playRecording() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename!)
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename!.path)
            Logger.logger.log(self, "playback started...\(audioRecorder.isRecording)")
            audioPlayer.delegate = self
            audioPlayer.play()
            Logger.logger.log(self, "playback playing...\(audioPlayer.isPlaying)")
        } catch let error {
            Logger.logger.reportError(self, "start playing", error)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Logger.logger.log(self, "playback stopped, ok:\(flag)")
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

//do {
    //recordingSession = AVAudioSession() //.sharedInstance()
    
    //try recordingSession.setCategory(.playAndRecord, mode: .default)
    
    //required otherwise recording wont start
    //try recordingSession.setCategory(.record, mode: .default) no need ? globa init??
    
//            try recordingSession.setActive(true)
//
//            recordingSession.requestRecordPermission() {allowed in
//                DispatchQueue.main.async {
//                    if !allowed {
//                        Logger.logger.reportError(self, "Record permission missing")
//                        return
//                    }
//                }
//            }
    
