import SwiftUI
import CoreData
import AVFoundation

class Metronome: ObservableObject {
    static public var shared:Metronome = Metronome()
    var tempo: Double = 60.0
    var clapCnt = 0
    @Published var clapCounter = 0
    var isRunning = false
    var isTicking = false
    private var score:Score?
    var scoreIndex = 0 
    private static var audioPlayers:[AVAudioPlayer] = []
    private static let numberOfAudioPlayers = 10
    
    static func initialize() {
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
        
        for _ in 0..<numberOfAudioPlayers {
            do {
                for _ in 0..<numberOfAudioPlayers {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.prepareToPlay()
                    audioPlayer.volume = 1.0 // Set the volume to full
                    //audioPlayer.prepareToPlay()
                    self.audioPlayers.append(audioPlayer)
                }
            }
            catch let error {
                Logger.logger.reportError("Cant create audio player", error)
            }
        }
    }
    
    func setTempo(tempo: Double) {
        self.tempo = tempo
    }
    
    func endTickNotify() {
        print("end of tick")
        AudioServicesDisposeSystemSoundID(1105);
    }
    
    func playScore(score:Score, onDone: (()->Void)? = nil) {
        self.score = score
        scoreIndex = 0
        if !self.isRunning {
            startRunning()
        }
    }

    private func startRunning() {
        self.isRunning = true
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let st = Date().timeIntervalSince1970
            var audioPlayerIdx = 0
            var loopCtr = 0
            var keepRunning = true
            
            while keepRunning {

                if self.isTicking {
                    let player = audioPlayerIdx % Metronome.audioPlayers.count
                    audioPlayerIdx += 1
                    Metronome.audioPlayers[player].play()
                }
                
                if let score = score {
                    if scoreIndex < score.scoreEntries.count {
                        let entry = score.scoreEntries[scoreIndex]
                        scoreIndex += 1
                        if entry is TimeSlice {
                            let ts:TimeSlice = entry as! TimeSlice
                            for note in ts.note {
                                note.setHilite()

                                let pitch = note.isOnlyRhythmNote ? Note.MIDDLE_C : note.midiNumber
                                Score.midiSampler.startNote(UInt8(pitch), withVelocity:48, onChannel:0)
                             }
                        }
                        if scoreIndex >= score.scoreEntries.count {
                            keepRunning = false
                        }
                        else {
                            //next time tick needs to have a time slice, e.g. throw away bar line entries
                            let entry = score.scoreEntries[scoreIndex]
                            if !(entry is TimeSlice) {
                                scoreIndex += 1
                            }
                        }
                    }
                }
                let t = Date().timeIntervalSince1970 - st
                print("  Metronome loop", "time:", String(format: "%.2f", t), "scoreIdx", scoreIndex)

                Thread.sleep(forTimeInterval: 60.0/self.tempo)
                loopCtr += 1
            }
            self.isRunning = false
        }
    }
    
    func startTicking() {
        if !self.isRunning {
            self.startRunning()
        }
        self.isTicking = true
    }
    
    func stopTicking() {
        self.isTicking = false
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


//var sampler:Sampler = Sampler(sf2File: "Metronom")
//var sampler:Sampler = Sampler(sf2File: "gm")
//var sampler:Sampler = Sampler(sf2File: "PNS Drum Kit")
//var sampler:Sampler = Sampler(sf2File: "Nice-Steinway-v3.8")
//var sampler:Sampler = Sampler(sf2File: "Nice-Bass-Plus-Drums-v5.3")
