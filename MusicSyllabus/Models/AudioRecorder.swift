import SwiftUI
import CoreData
import AVFoundation

class AudioRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename:URL?

    func startRecording()  {
        do {
            recordingSession = AVAudioSession() //.sharedInstance()
            //try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() {allowed in
                DispatchQueue.main.async {
                    if !allowed {
                        Logger.logger.reportError(self, "record permission missing")
                    }
                }
            }
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
                Logger.logger.log(self, "recording started...\(audioRecorder.isRecording)")
            } catch let error {
                print(error.localizedDescription)
                stopRecording()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //print("NOTIFY::did finish recording, success:", flag)
        //finishRecording(success: flag)
    }

    func stopRecording() {
        if audioRecorder != nil {
            Logger.logger.log(self, "recording ended from-\(audioRecorder.isRecording)")
            audioRecorder.stop()
            do {
                try recordingSession.setCategory(.playback, mode: .default)
                try recordingSession.setActive(true)
            }
            catch let error {
                print(error.localizedDescription)
            }
            //audioRecorder = nil
            recordingSession = nil
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
//==========================

//extension Recorder1: AVAudioRecorderDelegate {
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag {
//            print("Notified  - Recording finished successfully")
//        } else {
//            print("Notified  - Recording finished with errors")
//        }
//        print("Notified  - isRecording = \(audioRecorder?.isRecording ?? false)")
//    }
//}
//
//class Recorder1 : NSObject, AVAudioPlayerDelegate {
//    var audioRecorder: AVAudioRecorder!
//    var audioPlayer: AVAudioPlayer!
//    var audioFilename:URL?
//
//    func startRecording() {
//        //audioFilename = getDocumentsDirectory().appendingPathComponent("recording2.wav")
//        audioFilename = getDocumentsDirectory().appendingPathComponent("recording2.aiff")
//
//        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
//            if granted {
//                print("Microphone permission is granted")
//            }
//            else {
//                print("Microphone permission not granted")
//                return
//            }
//        }
//
//        do {
////
////            //.wav
////            let settings = [
////                AVFormatIDKey: Int(kAudioFormatLinearPCM),
////                AVSampleRateKey: 44100,
////                AVNumberOfChannelsKey: 1,
////                //AVEncoderBitRateKey: 12800,
////                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
////            ]
//
//            //.aif
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatLinearPCM),
//                AVSampleRateKey: 44100,
//                AVNumberOfChannelsKey: 2,
//                AVEncoderBitDepthHintKey: 16,
//                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ]
//            //try AVAudioSession.sharedInstance().setActive(true)
//            let audioSession = AVAudioSession.sharedInstance()
//            do {
//                try audioSession.setCategory(.playAndRecord, mode: .default)
//                try audioSession.setActive(true)
//                //try audioSession.setPreferredInput(audioSession.availableInputs?.first(where: { $0.portType == .builtInMicrophone }), options: [])
//            } catch {
//                print("Error setting up audio session: \(error.localizedDescription)")
//            }
//            //audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
//            print("starting record1", audioRecorder.isRecording)
//
////            let availableInputs = audioSession.availableInputs ?? []
////            for input in availableInputs {
////                if input.portType == .builtInMic {
////                   // let availableFormats = input.dataSources?.first?.supportedPolarPatterns.flatMap {
////
////                    }//.first?.supportedFormats
////                    print("Available audio formats for recording:")
//////                    for format in availableFormats ?? [] {
//////                        print("- \(format)")
//////                    }
//////                    break
////                }
////            }
//
//
//            audioRecorder.delegate = self
//            audioRecorder.prepareToRecord()
//            audioRecorder.record()
//            sleep(2)
//            print("starting record2", audioRecorder.isRecording)
//        } catch {
//            print("Error starting recording: \(error.localizedDescription)")
//        }
//    }
//
//    func stopRecording() {
//        if audioRecorder != nil {
//            print("Stopping record1....", audioRecorder.isRecording)
//            audioRecorder.stop()
//
//            print("Stopping record2....", audioRecorder.isRecording)
//            audioRecorder = nil
//        }
//    }
//
//    func playRecording() {
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename!)
//            print("Starting playback1....", audioPlayer.isPlaying)
//            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename!.path)
//            if let fileSize = attributes[.size] as? Int64 {
//                print("File size: \(fileSize) bytes")
//                //print(attributes.isEmpty)
//                //print(attributes.debugDescription)
//                //print(attributes.keys)
//            }
//            audioPlayer.delegate = self
//            audioPlayer.play()
//            print("Starting playback....", audioPlayer.isPlaying)
//        } catch {
//            print("\nError playing recording: \(error.localizedDescription)")
//        }
//    }
//
//    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//            print("============>Error encoding audio: \(error?.localizedDescription ?? "unknown error")")
//        }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            print("Playback finished successfully.")
//        } else {
//            print("Playback did not finish successfully.")
//        }
//    }
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
//}
//class AudioFilePlayer: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
//    var audioPlayer: AVAudioPlayer?
//
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
//
//    func playFile() {
//        // Set up the audio player with the recorded audio file
//        do {
//            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording1.wav")
//            if !FileManager.default.fileExists(atPath: audioFilename.path) {
//                print("File not exists")
//            }
//            let attributes = try FileManager.default.attributesOfItem(atPath: audioFilename.path)
//            if let fileSize = attributes[.size] as? Int64 {
//                print("File size: \(fileSize) bytes")
//                //print("All attributes", attributes)
//            }
//
//            print("=== file name", audioFilename)
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//        } catch {
//            print("Error initializing audio player: \(error)")
//        }
//
//        // Check if the audio player is initialized
//        guard let player = audioPlayer else {
//            print("Audio player not initialized")
//            return
//        }
//
//        // Play the recorded audio file
//        if !audioPlayer!.isPlaying {
//            audioPlayer!.play()
//            print("======>Player is playing???", audioPlayer!.isPlaying)
//        }
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            print("Audio playback finished successfully")
//        } else {
//            print("Audio playback finished with an error")
//        }
//    }
//
//    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
//        if let error = error {
//            print("Audio playback error: \(error)")
//        }
//    }
//}

// ====================
