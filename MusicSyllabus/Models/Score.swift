import Foundation
import AVKit
import AVFoundation

class ScoreEntry : Hashable {
    let id = UUID()
    static func == (lhs: ScoreEntry, rhs: ScoreEntry) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class Sampler {
    var sampler:AVAudioUnitSampler = AVAudioUnitSampler()
    var inited = false
    
    init(sf2File:String) {
        guard inited==false else {
            return
        }
        inited = true
        Score.engine.attach(sampler)
        Score.engine.connect(sampler, to:Score.engine.mainMixerNode, format:Score.engine.mainMixerNode.outputFormat(forBus: 0))
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
                if let url = Bundle.main.url(forResource:sf2File, withExtension:"sf2") {
                    try self.sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                    Logger.logger.log("loaded SF2 for sampler \(sf2File)")
                }
                else {
                    Logger.logger.reportError("Cant load SF2 for sampler \(sf2File)")
                }
                
            } catch let error {
                Logger.logger.reportError("Sampler cant load sound bank for sampler \(sf2File)", error)
            }
        }
    }
}

class BarLine : ScoreEntry {
    let atScoreEnd:Bool
    init(atScoreEnd:Bool = false) {
        self.atScoreEnd = atScoreEnd
    }
}

class Score : ObservableObject {
    static let engine = AVAudioEngine()
    static let midiSampler = AVAudioUnitSampler()
    
    static var auStarted = false
    var timeSignature:TimeSignature
    
    let ledgerLineCount = 3//4 is required to represent low E

    @Published var key:Key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
    @Published var showNotes = true
    @Published var showFootnotes = false

    private var staff:[Staff] = []
    var minorScaleType = Scale.MinorType.natural
    var tempo:Float = 75 //BPM, 75 = andante
    static let maxTempo:Float = 200
    static let minTempo:Float = 30
    static let midTempo:Float = Score.minTempo + (Score.maxTempo - Score.minTempo) / 2.0
    static let slowTempo:Float = Score.minTempo + (Score.maxTempo - Score.minTempo) / 4.0

    var staffLineCount = 0
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"
    var scoreEntries:[ScoreEntry] = []

    static func startAu()  {
        engine.attach(midiSampler)
        engine.connect(midiSampler, to:engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        Score.auStarted = true
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
                if let url = Bundle.main.url(forResource:"Nice-Steinway-v3.8", withExtension:"sf2") {
                    try Score.midiSampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
                }
                try Score.engine.start()
            } catch {
                print("Couldn't start engine")
            }
        }
        Logger.logger.log("Score::Initialised engine, connected sampler, started engine")
    }
    
    init(timeSignature:TimeSignature, lines:Int) {
        self.timeSignature = timeSignature
        staffLineCount = lines + (2*ledgerLineCount)
        //engine.attach(reverb)
        //reverb.loadFactoryPreset(.largeHall2)
        //reverb.loadFactoryPreset(
        //reverb.wetDryMix = 50

        // Connect the nodes.
        //engine.connect(sampler, to: reverb, format: nil)
        //engine.connect(reverb, to: engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        if !Score.auStarted {
            Score.startAu()
        }
    }
    
    func setShowFootnotes(_ on:Bool) {
        DispatchQueue.main.async {
            self.showFootnotes = on
        }
    }
    
    func toggleShowNotes() {
        DispatchQueue.main.async {
            self.showNotes = !self.showNotes
        }
    }
    
    func updateStaffs() {
        for staff in staff {
            staff.update()
        }
    }
    
    func setStaff(num:Int, staff:Staff) {
        if self.staff.count <= num {
            self.staff.append(staff)
        }
        else {
            self.staff[num] = staff
        }
    }
    
    func getStaff() -> [Staff] {
        return self.staff
    }
    
    func keyDesc() -> String {
        var desc = key.description()
        if key.type == Key.KeyType.minor {
            desc += minorScaleType == Scale.MinorType.natural ? " (Natural)" : " (Harmonic)"
        }
        return desc
    }
    
    func setKey(key:Key) {
        self.key = key
        DispatchQueue.main.async {
            self.key = key
        }
        updateStaffs()
    }

    func setTempo(temp: Int, pitch: Int? = nil) {
        self.tempo = Float(temp)
    }
    
    func addTimeSlice() -> TimeSlice {
        let ts = TimeSlice(score: self)
        self.scoreEntries.append(ts)
        return ts
    }
    
    func addBarLine(atScoreEnd:Bool? = false) {
        if let atScoreEnd = atScoreEnd {
            self.scoreEntries.append(BarLine(atScoreEnd: atScoreEnd))
        }
        else {
            self.scoreEntries.append(BarLine(atScoreEnd: false))
        }
    }

    func clear() {
        self.scoreEntries = []
        for staff in staff  {
            staff.clear()
        }
    }

    func playChord(chord: Chord, arpeggio: Bool? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            //let t = Score.maxTempo - tempo
            //var index = 0
            for note in chord.notes {
                let playTempo = 60.0/self.tempo
                //print(" ", note.num)
                //Score.sampler.startNote(UInt8(note.num + 12 + self.pitchAdjust), withVelocity:48, onChannel:0)
                //index += 1
                if let arp = arpeggio {
                    if arp  {
                        //if t > 0 {
                            usleep(useconds_t(playTempo * 500000))
                        //}
                    }
                }

            }
            //usleep(500000)
        }
    }
    

}
