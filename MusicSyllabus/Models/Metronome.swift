import SwiftUI
import CoreData
import AVFoundation

class Metronome: ObservableObject {
    
    static private var shared:Metronome = Metronome()
    
    let id = UUID()
    @Published var clapCounter = 0
    @Published var tempoName:String = ""
    @Published var tempo:Int = 60
    
    //must be instance of Metronome lifetime
    let midiNoteEngine = AVAudioEngine()

    var allowChangeTempo:Bool = false
    let tempoMinimumSetting = 40
    let tempoMaximumSetting = 120

    var clapCnt = 0
    var isThreadRunning = false
    private var score:Score?
    var nextScoreIndex = 0
    private var nextTimeSlice:TimeSlice?
    private var currentNoteDuration = 0.0
    
    var isTickingWithScorePlay = false
    
    //the shortest note value which is used to set the metronome's thread firing frequency
    private let shortestNoteValue = Note.VALUE_QUAVER
    
    private let speech = SpeechSynthesizer.shared
    var speechEnabled = false
    
    static func getMetronomeWithCurrentSettings() -> Metronome {
        //print("** Get Metronome, Current Settings, ID:", Metronome.shared.id, Metronome.shared.tempo)
        let met = Metronome.shared
        met.isTickingWithScorePlay = false
        return met
    }
    
    static func getMetronomeWithStandardSettings() -> Metronome {
        let met = Metronome.getMetronomeWithSettings(initialTempo: 60, allowChangeTempo: false)
        met.isTickingWithScorePlay = false
        //print("** Get Metronome, Standard Settings, ID:", met.id, met.tempo)
        return met
    }

    static func getMetronomeWithSettings(initialTempo:Int, allowChangeTempo:Bool) -> Metronome {
        shared.setTempo(tempo: initialTempo)
        shared.allowChangeTempo = allowChangeTempo
        shared.isTickingWithScorePlay = false
        //print("** Get Metronome, WithSettings (Specific), ID:", Metronome.shared.id, Metronome.shared.tempo)
        return Metronome.shared
    }
    
    private init() {
    }
    
    func getMidiAudioSampler() -> AVAudioUnitSampler {
        let midiSampler:AVAudioUnitSampler
        
        //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
        //https://sites.google.com/site/soundfonts4u/
        var soundFontNames = [("Piano", "Nice-Steinway-v3.8"), ("Guitar", "GuitarAcoustic")]
        var samplerFileName = soundFontNames[0].1
        
        AppDelegate.startAVAudioSession(category: .playback)
        midiSampler = AVAudioUnitSampler()
        midiNoteEngine.attach(midiSampler)
        midiNoteEngine.connect(midiSampler, to:midiNoteEngine.mainMixerNode, format:midiNoteEngine.mainMixerNode.outputFormat(forBus: 0))
        //18May23 -For some unknown reason and after hours of investiagtion this loadSoundbank must oocur before every play, not jut at init time
        
        if let url = Bundle.main.url(forResource:samplerFileName, withExtension:"sf2") {
            for i in 0..<256 {
                do {
                    try midiSampler.loadSoundBankInstrument(at: url, program: UInt8(i), bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                    break
                }
                catch {
                }
            }

        }
        else {
            Logger.logger.reportError(self, "Cannot loadSoundBankInstrument \(samplerFileName)")
        }
        
        do {
            try midiNoteEngine.start()
        }
        catch let error {
            Logger.logger.reportError(self, "Cant create MIDI sampler \(error.localizedDescription)")
        }
        
        return midiSampler
    }
    
    func setTempo(tempo: Int) {
        //https://theonlinemetronome.com/blogs/12/tempo-markings-defined
        if tempo < self.tempoMinimumSetting || tempo > self.tempoMaximumSetting {
            //an attempt to set the tempo with a student's unreasonable tempo should fail
            return
        }
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
        if tempo > 200 {
        }
        DispatchQueue.main.async {
            self.tempoName = name
            self.tempo = tempo
        }
    }
    
    func playScore(score:Score, rhythmNotesOnly:Bool=false, onDone: (()->Void)? = nil) {
        self.score = score
        
        let audioSamplerMIDI = getMidiAudioSampler()
        var audioTicker:AudioSamplerPlayer = AudioSamplerPlayer(timeSignature: score.timeSignature)
        
        //find the first note to play
        nextScoreIndex = 0
        if score.scoreEntries.count > 0 {
            if score.scoreEntries[0] is TimeSlice {
                let next = score.scoreEntries[0] as! TimeSlice
                if next.notes.count > 0 {
                    self.nextTimeSlice = next
                    currentNoteDuration = nextTimeSlice!.notes[0].getValue()
                }
            }
        }
        nextScoreIndex = 1
        
        if !self.isThreadRunning {
            startThreadRunning(audioTicker: audioTicker, audioSamplerPlayerMIDI:audioSamplerMIDI, onDone: onDone)
        }
        setTempo(tempo: self.tempo)
    }
    
    func stopPlayingScore() {
        self.score = nil
    }

    private func startThreadRunning(audioTicker:AudioSamplerPlayer?, audioSamplerPlayerMIDI:AVAudioUnitSampler?, numberOfTicks:Int? = nil, onDone: (()->Void)? = nil) {
        self.isThreadRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
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
                    if self.isTickingWithScorePlay {
                        if let ticker = audioTicker {
                            ticker.play()
                        }
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
                            let channel = 0
                            var noteInChordNum = 0
                            for note in timeSlice.notes {
                                if currentNoteDuration < note.getValue() {
                                    //note only plays once even though it might spans > 1 tick
                                    continue
                                }
                                note.setHilite(hilite: true)
                                DispatchQueue.global(qos: .background).async {
                                    Thread.sleep(forTimeInterval: 0.5)
                                    note.setHilite(hilite: false)
                                }
                                if note.isOnlyRhythmNote  {
                                    if let audioTicker = audioTicker {
                                        audioTicker.play(noteValue: note.getValue())
                                    }
                                }
                                else {
                                    if let audioPlayer = audioSamplerPlayerMIDI {
                                        audioPlayer.startNote(UInt8(note.midiNumber), withVelocity:64, onChannel:UInt8(channel))
                                    }
                                }
                                if noteInChordNum == 0 && note.getValue() < 1.0 {
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
                                    if entry is TimeSlice {
                                        nextTimeSlice = entry as! TimeSlice
                                        if nextTimeSlice!.notes.count > 0 {
                                            nextScoreIndex += 1
                                            currentNoteDuration = nextTimeSlice!.notes[0].getValue()
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
                        }
                    }
                }

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
                
                if score == nil {
                    //currenlty metronome only runs when a score is attached. In future it could run without a score - i.e. to measure time
                    keepRunning = false
                }
                else {
                    //if !self.isTicking {
                    keepRunning = nextTimeSlice != nil
                    //}
                    if let numberOfTicks = numberOfTicks {
                        if loopCtr >= numberOfTicks - 1 {
                            keepRunning = false
                        }
                    }
                }
                let sleepTime = (60.0 / Double(self.tempo)) * shortestNoteValue
                Thread.sleep(forTimeInterval: sleepTime)
                loopCtr += 1
            }
            self.isThreadRunning = false
            //self.isTicking = false
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

