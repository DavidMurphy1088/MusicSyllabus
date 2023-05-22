import SwiftUI
import CoreData
import AVFoundation

class TapRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, ObservableObject {
    static let shared = TapRecorder()
    
    var times:[Double] = []
    
    @Published var status:String = ""
    
    func setStatus(_ msg:String) {
        DispatchQueue.main.async {
            self.status = msg
        }
    }
    
    func startRecording()  {
        print("TapRecorder::started rec")
    }
    
    func clap()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        print(dateString)
        self.times.append(date.timeIntervalSince1970)
    }

    func stopRecording() {
        print("TapRecorder::ended rec")
    }

    func playRecording() {
        print("TapRecorder::play")
        var last:Double? = nil
        for t in times {
            var diff = 0.0
            if last != nil {
                diff = (t - last!) 
            }
            print(String(format: "%.10f", t), "\t", String(format: "%.4f", diff))
            last = t
        }
    }

}

