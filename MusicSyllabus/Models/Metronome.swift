import SwiftUI
import CoreData
import AVFoundation

class Metronome: ObservableObject {
    static public var shared:Metronome = Metronome()
    let midiNoteEngine = AVAudioEngine()
    
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
    private let numberOfAudioPlayers = 16 //Need > 1 since only one cannot sound again within the required tick frequency
    private var nextTimeSlice:TimeSlice?
    private var currentNoteDuration = 0.0
    //the shortest note value which is used to set the metronome's thread firing frequency
    private let shortestNoteValue = Note.VALUE_QUAVER
    private var clapURL:URL? = nil
    private let speech = SpeechSynthesizer.shared
    var speechEnabled = false
    
    var samplerFileName = ""
    var soundFontNames = [("Piano", "Nice-Steinway-v3.8"), ("Guitar", "GuitarAcoustic")]
    //var soundFontSF2Files = ["Nice-Steinway-v3.8", "GuitarAcoustic"]
    var soundFontProgram = 0

    init() {
        self.tempo = 60.0
        let wav = false
        //var url:URL?
        //let name = "Envalentoned_violin"
        //let name = "Nice-Steinway-v3.8"
        //let name = "GuitarAcoustic"
        //self.samplerFileName = "Essential Keys-sforzando-v9.6"

        self.samplerFileName = soundFontNames[0].1
        
        if wav {
            guard let tickSoundPath = Bundle.main.path(forResource: "clap-single-17", ofType: "wav") else {
                Logger.logger.reportError(self, "Cannot load WAV file")
                return
            }
            self.clapURL = URL(fileURLWithPath: tickSoundPath)
        }
        else {
            //url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
            //url = Bundle.main.url(forResource: "Mechanical metronome - Low", withExtension: "aif")
            clapURL = Bundle.main.url(forResource: "Mechanical metronome - High", withExtension: "aif")
            do {
                for _ in 0..<self.numberOfAudioPlayers {
                    let audioPlayer = try AVAudioPlayer(contentsOf: self.clapURL!)
                    if audioPlayer != nil {
                        self.audioPlayers.append(audioPlayer)
                        audioPlayer.prepareToPlay()
                        audioPlayer.volume = 1.0 // Set the volume to full
                        audioPlayer.rate = 2.0
                    }
                    else {
                        Logger.logger.reportError(self, "AVAudioPlayer cant load bundle")
                    }
                }
            }
            catch  {
                Logger.logger.reportError(self, "Cannot prepare AVAudioPlayer")
            }
        }
        guard let url = clapURL else {
            Logger.logger.reportError(self, "Clap URL is nil")
            return
        }
        
        // ========= set up audio sampler ============
        
        //midiSampler = AVAudioUnitSampler()
        //engine.attach(midiSampler!)
        //engine.connect(midiSampler!, to:engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        
        //        do {
        //            //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
        //            if let url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
        //                try self.midiSampler!.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
        //            }
        //            //try self.engine.start()
        //        } catch let error {
        //            Logger.logger.reportError(self, "loading sampler", error)
        //        }
        //        Logger.logger.log(self, "Score::Initialised engine, connected sampler, started engine")
        
    }
    

    func startAudio() {
        guard self.clapURL != nil else {
            return
        }
        AppDelegate.startAVAudioSession(category: .playback)
        do {
//                audioPlayers = []
//                for _ in 0..<numberOfAudioPlayers {
//                    let audioPlayer = try AVAudioPlayer(contentsOf: self.clapURL!)
//                    audioPlayer.prepareToPlay()
//                    audioPlayer.volume = 1.0 // Set the volume to full
//                    audioPlayers.append(audioPlayer)
//                }
            midiSampler = AVAudioUnitSampler()
            midiNoteEngine.attach(midiSampler!)
            midiNoteEngine.connect(midiSampler!, to:midiNoteEngine.mainMixerNode, format:midiNoteEngine.mainMixerNode.outputFormat(forBus: 0))
            //18May23 -For some unknown reason and after hours of investiagtion this loadSoundbank must oocur before every play, not jut at init time
            //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
            //https://sites.google.com/site/soundfonts4u/
            
            //printInstruments(name: name)
            if let url = Bundle.main.url(forResource:self.samplerFileName, withExtension:"sf2") {
                print(url)
                try self.midiSampler!.loadSoundBankInstrument(at: url, program: UInt8(self.soundFontProgram), bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
            }
            else {
                Logger.logger.reportError(self, "Cannot loadSoundBankInstrument \(self.samplerFileName)")
            }
            try self.midiNoteEngine.start()
        }
        catch let error {
            Logger.logger.reportError(self, "Cant create midi sampler \(error.localizedDescription)")
        }
        setTempo(tempo: self.tempo)
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
        if tempo > 40 && tempo <= 59 {
            name = "Lento"
        }
//        if tempo > 60 && tempo <= 66 {
//            name = "Larghetto"
//        }
        if tempo > 59 && tempo <= 72 {
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
            //Logger.logger.log(self, "set tempo \(self.tempo)")
        }
    }
    
    func playScore(score:Score, onDone: (()->Void)? = nil) {
        self.startAudio()
        
        self.score = score
        nextScoreIndex = 0
        
        //find the first note to play
        if score.scoreEntries.count > 0 {
            if score.scoreEntries[0] is TimeSlice {
                let next = score.scoreEntries[0] as! TimeSlice
                if next.notes.count > 0 {
                    self.nextTimeSlice = next
                    currentNoteDuration = nextTimeSlice!.notes[0].value
                }
            }
        }
        nextScoreIndex = 1
        if !self.isThreadRunning {
            startThreadRunning(onDone: onDone)
        }
    }
    
    func startTicking(numberOfTicks:Int? = nil, onDone: (()->Void)? = nil) {
        if !self.isThreadRunning {
            //self.startAudio(needMidi: false)
            self.startThreadRunning(numberOfTicks: numberOfTicks, onDone: onDone)
        }
        self.isTicking = true
    }
    
    func stopPlayingScore(note:Int? = 0) {
        self.score = nil
        if let note = note {
            midiSampler?.stopNote(UInt8(note), onChannel: 0)
        }
    }

    func stopTicking() {
        self.isTicking = false
    }
    
    private func startThreadRunning(numberOfTicks:Int? = nil, onDone: (()->Void)? = nil) {
        self.isThreadRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var audioPlayerIdx = 0
            var loopCtr = 0
            var keepRunning = true
            var playSynched = false
            var currentTimeValue = 0.0
            var noteValueSpeechWord:String? = nil
            var ticksPlayed = 0
            
            while keepRunning {
                noteValueSpeechWord = nil
                
                // sound the metronome tick
                if loopCtr % 2 == 0 {
                    if self.isTicking {
                        let idx = audioPlayerIdx % audioPlayers.count
                        audioPlayerIdx += 1
                        //audioPlayers[idx].prepareToPlay()
                        //audioPlayers[idx].volume = 1.0

                        audioPlayers[idx].play()
                        ticksPlayed += 1
                        if score != nil {
                            playSynched = true
                        }
                    }
                    else {
                        playSynched = true
                    }
                }
                
                //sound the next note
                if playSynched {
                    if let score = score {
                        if let timeSlice = nextTimeSlice {
                            var channel = 0
                            var noteInChordNum = 0
                            for note in timeSlice.notes {
                                //print("    ---", note.midiNumber)
                                if currentNoteDuration < note.value {
                                    //note only plays once even though it might spans > 1 tick
                                    continue
                                }
                                note.setHilite(hilite: true)
                                DispatchQueue.global(qos: .background).async {
                                    Thread.sleep(forTimeInterval: 0.5)
                                    note.setHilite(hilite: false)
                                }
                                let pitch = note.isOnlyRhythmNote ? Note.MIDDLE_C : note.midiNumber
                                midiSampler!.startNote(UInt8(pitch), withVelocity:64, onChannel:UInt8(channel))
                                if noteInChordNum == 0 && note.value < 1.0 {
                                    noteValueSpeechWord = "and"
                                }
                                noteInChordNum += 1
                            }
                            
                            //determine what time slice comes on the next tick. e.g. maybe the current time slice needs > 1 tick
                            //next time tick needs to have a time slice, e.g. throw away bar line entries
                            currentNoteDuration -= self.shortestNoteValue //1
                            if currentNoteDuration <= 0 {
                                nextTimeSlice = nil
                                while nextScoreIndex < score.scoreEntries.count {
                                    let entry = score.scoreEntries[nextScoreIndex]
                                    //print("==", type(of: entry))
                                    if entry is TimeSlice {
                                        nextTimeSlice = entry as! TimeSlice
                                        if nextTimeSlice!.notes.count > 0 {
                                            nextScoreIndex += 1
                                            currentNoteDuration = nextTimeSlice!.notes[0].value
                                            break
                                        }
                                        else {
                                            let barLine = entry as! BarLine
                                            if barLine != nil {
                                                currentTimeValue = 0
                                            }
                                        }
                                    }
                                    nextScoreIndex += 1
                                }
                            }
                            //keepRunning = nextTimeSlice != nil
                            if nextTimeSlice == nil {
//                                if let onDone = onDone {
//                                    onDone()
//                                }
                            }
                        }
                    }
                }
                //let t = Date().timeIntervalSince1970 - st
                //print("  Metronome loop", "time:", String(format: "%.2f", t), "scoreIdx", nextScoreIndex)
                
                
                if speechEnabled {
                    if loopCtr % 2 == 0 {
                        let word = noteCoundSpeechWord(currentTimeValue: currentTimeValue)
                        speech.speakWord(word)
                    }
                    else {
                        //quavers say 'and'
                        if noteValueSpeechWord != nil {
                            speech.speakWord(noteValueSpeechWord!)
                        }
                    }
                }
                currentTimeValue += shortestNoteValue
                
                if !self.isTicking {
                   keepRunning = nextTimeSlice != nil
                }
                if let numberOfTicks = numberOfTicks {
                    if loopCtr >= numberOfTicks - 1 {
                        keepRunning = false
                    }
                }
                let sleepTime = (60.0/self.tempo) * shortestNoteValue
                Thread.sleep(forTimeInterval: sleepTime)
                loopCtr += 1
            }
            //print ("===> metronome thread stopped")
            self.isThreadRunning = false
            self.isTicking = false
            if let onDone = onDone {
                onDone()
            }

        }
    }
    
    func noteCoundSpeechWord(currentTimeValue:Double) -> String {
        var word = ""
        if currentTimeValue.truncatingRemainder(dividingBy: 1) == 0 {
            let cvInt = Int(currentTimeValue)
            if let score = score {
                switch cvInt %  score.timeSignature.top {
                case 0 :
                    word = "one"
                    
                case 1 :
                    word = "two"
                    
                case 2 :
                    word = "three"
                    
                default :
                    word = "four"
                }
            }
        }
        else {
            word = ""
        }
        return word
    }
}

