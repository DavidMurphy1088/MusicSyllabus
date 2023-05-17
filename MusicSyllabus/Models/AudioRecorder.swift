import SwiftUI
import CoreData
import AVFoundation

class AudioRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename:URL?

    func startRecording()  {
        //do {
            //recordingSession = AVAudioSession() //.sharedInstance()
            recordingSession = AVAudioSession.sharedInstance()
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
            
            AppDelegate.startAVAudioSession(category: .record)
            
            audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            
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
                Logger.logger.log(self, "Recording started...\(audioRecorder.isRecording)")
            } catch let error {
                Logger.logger.reportError(self, "Recording did not start", error)
                stopRecording()
            }
//        } catch let error {
//            Logger.logger.reportError(self, "Audio record error", error)
//        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //print("NOTIFY::did finish recording, success:", flag)
        //finishRecording(success: flag)
    }

    func stopRecording() {
        if audioRecorder != nil {
            Logger.logger.log(self, "Recording ended OK -\(audioRecorder.isRecording)")
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
