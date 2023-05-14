//import SwiftUI
//import CoreData
//import AVFoundation
//
//class AudioRecorder1 : NSObject, AVAudioRecorderDelegate {
//    let audioSession = AVAudioSession.sharedInstance()
//    var audioRecorder:AVAudioRecorder?
//    
//    func startRecording() {
//        audioSession.requestRecordPermission { [self] (granted: Bool) -> Void in
//            if granted {
//                print("Microphone permission granted")
//            } else {
//                print("Microphone permission denied")
//                audioSession.requestRecordPermission { granted in
//                    if granted {
//                        // Permission granted, start recording
//                    } else {
//                        // Permission not granted, handle error
//                    }
//                }
//            }
//        }
//
//        let audioFilenameURL = getDocumentsDirectory().appendingPathComponent("recording1.wav")
//        print(audioFilenameURL, type(of: audioFilenameURL))
//        if FileManager.default.fileExists(atPath: audioFilenameURL.path) {
//            print("File already exists")
//        }
////        if fileManager.fileExists(atPath: audioFilenameURL) {
////            print("File exists!")
////        } else {
////            print("File does not exist.")
////        }
//        print("Audio file path: \(audioFilenameURL.path)")
//
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatLinearPCM),
//            AVSampleRateKey: 44100,
//            AVNumberOfChannelsKey: 2,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            //try audioSession.setCategory(.record, mode: .default, options: [])
//            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
//            try audioSession.setActive(true)
//
//            audioRecorder = try AVAudioRecorder(url: audioFilenameURL, settings: settings)
//            if let audioRecorder = audioRecorder {
//                audioRecorder.delegate = self
//                audioRecorder.prepareToRecord()
//                if !audioRecorder.isRecording {
//                    audioRecorder.record()
//                    print("=====>IS RECORDING?", audioRecorder.isRecording)
//                }
//            }
//        } catch {
//            print("Error initializing audio recorder: \(error.localizedDescription)")
//        }
//    }
//
//    func stopRecording() {
//        if let audioRecorder = audioRecorder {
//            if audioRecorder.isRecording {
//                audioRecorder.stop()
//                print("=========recorder stopped")
//            }
//        }
//    }
//
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
//
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag {
//            print("Audio recording finished successfully")
//        } else {
//            print("Audio recording finished with an error")
//        }
//    }
//
//    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//        if let error = error {
//            print("Audio recording error: \(error)")
//        }
//    }
//}
//
