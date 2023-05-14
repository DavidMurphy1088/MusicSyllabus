import SwiftUI
import CoreData
import AVFoundation

class Metronome: ObservableObject {
    static public var shared:Metronome = Metronome()
    let engine = AVAudioEngine()
    
    @Published var clapCounter = 0
    @Published var tempoName:String = ""
    var midiSampler:AVAudioUnitSampler?
    
    var tempo: Double
    var clapCnt = 0

    var isThreadRunning = false
    var isTicking = false
    private var score:Score?
    var nextScoreIndex = 0 
    private var audioPlayers:[AVAudioPlayer] = []
    private let numberOfAudioPlayers = 10
    private var nextTimeSlice:TimeSlice?
    private var currentNoteDuration = 0.0
    //the shortest note value which is used to set the metronome's thread firing frequency
    private let shortestNoteValue = Note.VALUE_QUAVER
    
    init() {
        self.tempo = 60.0

        let wav = false
        var url:URL?
        if wav {
            guard let tickSoundPath = Bundle.main.path(forResource: "clap-single-17", ofType: "wav") else {
                Logger.logger.reportError(self, "Cannot load WAV file")
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
            Logger.logger.reportError(self, "URL is nil")
            return
        }
        
        for _ in 0..<numberOfAudioPlayers {
            do {
                for _ in 0..<numberOfAudioPlayers {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.prepareToPlay()
                    audioPlayer.volume = 1.0 // Set the volume to full
                    audioPlayers.append(audioPlayer)
                }
            }
            catch let error {
                Logger.logger.reportError(self, "Cant create audio player", error)
            }
        }
        
        // ========= set up audio ============
        
        midiSampler = AVAudioUnitSampler()
        engine.attach(midiSampler!)
        engine.connect(midiSampler!, to:engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        
        //DispatchQueue.global(qos: .userInitiated).async {
            do {
                //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
                if let url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
                    try self.midiSampler!.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                }
                try self.engine.start()
            } catch let error {
                Logger.logger.reportError(self, "loading sampler", error)
            }
        //}
        Logger.logger.log(self, "Score::Initialised engine, connected sampler, started engine")
    }
    
    func setTempo(tempo: Double) {
        //https://theonlinemetronome.com/blogs/12/tempo-markings-defined
        self.tempo = tempo
        var name = ""
        if tempo <= 20 {
            name = "Larghissimo"
        }
        if tempo > 20 && tempo <= 40 {
            name = "Solenne/Grave"
        }
        if tempo > 40 && tempo <= 60 {
            name = "Lento"
        }
        if tempo > 60 && tempo <= 66 {
            name = "Larghetto"
        }
        if tempo > 66 && tempo <= 72 {
            name = "Adagio"
        }
        if tempo > 72 && tempo <= 76 {
            name = "Andante"
        }
        if tempo > 76 && tempo <= 83 {
            name = "Andantino"
        }
        if tempo > 83  && tempo <= 120 {
            name = "Moderato"
        }
        if tempo > 120  && tempo <= 128 {
            name = "Allegretto"
        }
        if tempo > 128  && tempo <= 180 {
            name = "Allegro"
        }
        if tempo > 180  {
            name = "Presto"
        }
        DispatchQueue.main.async {
            self.tempoName = name
            Logger.logger.log(self, "set tempo \(self.tempo)")
        }
    }
    
    func playScore(score:Score, onDone: (()->Void)? = nil) {
        self.score = score
        nextScoreIndex = 0
        
        //find the first note to play
        if score.scoreEntries.count > 0 {
            if score.scoreEntries[0] is TimeSlice {
                let next = score.scoreEntries[0] as! TimeSlice
                if next.note.count > 0 {
                    self.nextTimeSlice = next
                    currentNoteDuration = nextTimeSlice!.note[0].value
                }
            }
        }
        nextScoreIndex = 1
        if !self.isThreadRunning {
            startThreadRunning()
        }
    }

    private func startThreadRunning() {
        self.isThreadRunning = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error {
            Logger.logger.reportError(self, "Set Category", error)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var audioPlayerIdx = 0
            var loopCtr = 0
            var keepRunning = true
            
            while keepRunning {
                
                // sound the metronome tick
                if self.isTicking {
                    let player = audioPlayerIdx % audioPlayers.count
                    audioPlayerIdx += 1
                    audioPlayers[player].play()
                }
                
                //sound the next note
                if let score = score {
                    if let timeSlice = nextTimeSlice {
                            for note in timeSlice.note {
                                if currentNoteDuration < note.value {
                                    //note only plays once even though it might spans > 1 tick
                                    continue
                                }
                                note.setHilite(way: true)
                                DispatchQueue.global(qos: .background).async {
                                    Thread.sleep(forTimeInterval: 0.5)
                                    note.setHilite(way: false)
                                }
                                let pitch = note.isOnlyRhythmNote ? Note.MIDDLE_C : note.midiNumber
                                midiSampler!.startNote(UInt8(pitch), withVelocity:64, onChannel:0)
                                print("METRONOME::payed midi", pitch)
                            }
                        
                        //determine what time slice comes on the next tick. e.g. maybe the current time slice needs > 1 tick
                        //next time tick needs to have a time slice, e.g. throw away bar line entries
                        currentNoteDuration -= self.shortestNoteValue //1
                        if currentNoteDuration > 0 {
                            
                        }
                        else {
                            nextTimeSlice = nil
                            while nextScoreIndex < score.scoreEntries.count {
                                let entry = score.scoreEntries[nextScoreIndex]
                                //print("==", type(of: entry))
                                if entry is TimeSlice {
                                    nextTimeSlice = entry as! TimeSlice
                                    if nextTimeSlice!.note.count > 0 {
                                        nextScoreIndex += 1
                                        currentNoteDuration = nextTimeSlice!.note[0].value
                                        break
                                    }
                                }
                                nextScoreIndex += 1
                            }
                        }
                        keepRunning = nextTimeSlice != nil
                    }
                }
                //let t = Date().timeIntervalSince1970 - st
                //print("  Metronome loop", "time:", String(format: "%.2f", t), "scoreIdx", nextScoreIndex)

                if !self.isThreadRunning && nextTimeSlice == nil {
                    keepRunning = false
                }
                Thread.sleep(forTimeInterval: (60.0/self.tempo) * shortestNoteValue)
                loopCtr += 1
            }
            //print ("===> metronome thread stopped")
            self.isThreadRunning = false
            self.isTicking = false
        }
    }
    
    func startTicking() {
        self.score = nil
        if !self.isThreadRunning {
            self.startThreadRunning()
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
