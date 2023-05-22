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
            if audioRecorder == nil {
                Logger.logger.reportError(self, "Recording, audio record is nil")
            }
            audioRecorder.delegate = self
            audioRecorder.record()
            Logger.logger.log(self, "Recording started - isRecording?: \(audioRecorder.isRecording)")
            if audioRecorder.isRecording {
                setStatus("Recording started")
            }
            else {
                Logger.logger.reportError(self, "Recording, recorder is not recording")
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
        Logger.logger.log(self, "Trying to stop recorder")
        if audioRecorder == nil {
            Logger.logger.reportError(self, "audioRecorder is nil at stop")
        }
        else {
            Logger.logger.log(self, "Recording ended - wasRecording? -\(audioRecorder.isRecording) secs:\(String(format: "%.1f", audioRecorder.currentTime))")
            setStatus("Recorded time \(String(format: "%.1f", audioRecorder.currentTime)) seconds")
            audioRecorder.stop()
//            do {
////                try recordingSession.setCategory(.playback, mode: .default)
////                try recordingSession.setActive(true) //DONT DO
////                try recordingSession.setCategory(.playback, mode: .default)
//            }
//            catch let error {
//                Logger.logger.reportError(self, "Recording ended with error", error)
//            }
            AppDelegate.startAVAudioSession(category: .playback)
            //audioRecorder = nil
            //recordingSession = nil
        }
    }

    func playRecording() {
        Logger.logger.log(self, "Playback starting")
        AppDelegate.startAVAudioSession(category: .playback)
        guard let url = audioFilename else {
            Logger.logger.reportError(self, "At playback, file URL is nil")
            return
        }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            Logger.logger.reportError(self, "At playback, file does not exist \(url.path)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename!)
            if audioPlayer == nil {
                Logger.logger.reportError(self, "At playback, cannot create audio player for \(url.path)")
                return
            }
            let msg = "playback started...\(audioRecorder.isRecording)"
            setStatus(msg)
            Logger.logger.log(self, "playback started, still recording:\(audioRecorder.isRecording)")
            audioPlayer.delegate = self
            audioPlayer.play()
            Logger.logger.log(self, "playback playing...\(audioPlayer.isPlaying)")
        } catch let error {
            Logger.logger.reportError(self, "At Playback, start playing error", error)
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

