import SwiftUI
import CoreData
import AVFoundation

class AudioRecorder : NSObject, AVAudioRecorderDelegate {
    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder:AVAudioRecorder?
    
    func startRecording() {
        audioSession.requestRecordPermission { (granted: Bool) -> Void in
            if granted {
                print("Microphone permission granted")
            } else {
                print("Microphone permission denied")
            }
        }
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        print("Audio file path: \(audioFilename.path)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            if let audioRecorder = audioRecorder {
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                if !audioRecorder.isRecording {
                    audioRecorder.record()
                }
            }
        } catch {
            print("Error initializing audio recorder: \(error)")
        }
    }
    
    func stopRecording() {
        if let audioRecorder = audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.stop()
                print("=========recorder stopped")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Audio recording finished successfully")
        } else {
            print("Audio recording finished with an error")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio recording error: \(error)")
        }
    }
}

