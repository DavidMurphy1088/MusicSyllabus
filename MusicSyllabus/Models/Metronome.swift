import SwiftUI
import CoreData
import AVFoundation

class Metronome: ObservableObject {

    //var sampler:Sampler = Sampler(sf2File: "Metronom")
    
    //var sampler:Sampler = Sampler(sf2File: "gm")
    //var sampler:Sampler = Sampler(sf2File: "PNS Drum Kit")
    //var sampler:Sampler = Sampler(sf2File: "Nice-Steinway-v3.8")
    //var sampler:Sampler = Sampler(sf2File: "Nice-Bass-Plus-Drums-v5.3")
    var tempo: Double = 1000
    
    //var captureSession:AVCaptureSession = AVCaptureSession()
    //var captureCtr = 0
    
    //static let requiredDecibelChangeInitial = 5 //16
    //static let requiredBufSizeInitial = 32
    
    //private var requiredDecibelChange = ClapRecorder.requiredDecibelChangeInitial
    //private var requiredBufSize = ClapRecorder.requiredBufSizeInitial

    var audioPlayers:[AVAudioPlayer] = []
    var clapCnt = 0
    @Published var clapCounter = 0
    var tickIsOn = false
    //private var timer: DispatchSourceTimer?
    
    func setTempo(tempo: Double) {
        self.tempo = tempo
    }
    
    func endTickNotify() {
        print("end of tick")
        AudioServicesDisposeSystemSoundID(1105);
    }
    
    func playTickSound() {
        //print("===== start Score.sampler.startNote....")
        self.tickIsOn = true
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let st = Date().timeIntervalSince1970
            var index = 0
            var playerIdx = 0
            let beats = [0, -1, 2, -1, 4, -1, 6, -1]
            while self.tickIsOn {
                let playNote = true //beats.contains(index % beats.count)
                if playNote {
                    let player = playerIdx % self.audioPlayers.count
                    playerIdx += 1
                    self.audioPlayers[player].play()
                    //sampler.sampler.startNote(UInt8(60+ctr), withVelocity:48, onChannel:0)
                }
                let t = Date().timeIntervalSince1970 - st
                print("  startNote", index, "time:", String(format: "%.2f", t), "note", playNote)
                Thread.sleep(forTimeInterval: self.tempo/1000.0)
                index += 1
            }
        }
    }
    
    func startMetronome() {
        let wav = false
        var url:URL?
        let sf2 = ""
        
        if wav {
            guard let tickSoundPath = Bundle.main.path(forResource: "clap-single-17", ofType: "wav") else {
                Logger.logger.reportError("Cannot load WAV file")
                return
            }
            url = URL(fileURLWithPath: tickSoundPath)
        }
        else {
            //url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
            //url = Bundle.main.url(forResource: "Mechanical metronome - Low", withExtension: "aif")
            url = Bundle.main.url(forResource: "Mechanical metronome - High", withExtension: "aif")
        }
        guard let url = url else {
            Logger.logger.reportError("URL is nil")
            return
        }
        
        do {
            for _ in 0..<20 {
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0 // Set the volume to full
                audioPlayer.prepareToPlay()
                self.audioPlayers.append(audioPlayer)
            }

            self.playTickSound()
        } catch let error {
            Logger.logger.reportError("Start tick", error)
            return
        }
    }
}


//      Time a metronome using a notify from a time - not as accurate as needed
//    func playScheduledTimerTick() {
//        print("===== start timer....")
//        var ctr = 0
//        let st = Date().timeIntervalSince1970
//        self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
//        //var sid = 1105 //1000 //1105
//        if self.timer != nil {
//            self.tickIsOn = true
//            self.timer!.schedule(deadline: .now(), repeating: .milliseconds(Int(tempo)), leeway: .milliseconds(1))
//            self.timer!.setEventHandler {
//                let t = Date().timeIntervalSince1970 - st
//                let play = true //[0, 2, 4, 6].contains(cx)
//                //print("....", ctr, String(format: "%.2f", t), play, sid)
//                //1009 1052
//                if play {
//                    //tickSoundPlayer.play()
//                    DispatchQueue.global(qos: .background).async {
//                        //https://github.com/TUNER88/iOSSystemSoundsLibrary
//                        //AudioServicesDisposeSystemSoundID(SystemSoundID(sid));
//                        //AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(sid), self.endTickNotify)
//                        let n = ctr % self.audioPlayers.count
//                        self.audioPlayers[n].play()
//                        print("  played tick", n)
//                        //sid += 1
//                    }
//                }
//                if self.tickIsOn == false {
//                    self.timer?.cancel()
//                }
//                ctr += 1
//            }
//            self.timer!.resume()
//        }
//    }
