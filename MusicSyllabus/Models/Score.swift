import Foundation
import AVKit
import AVFoundation

class ScoreEntry : Hashable {
    let id = UUID()
    var sequence:Int = 0
    static func == (lhs: ScoreEntry, rhs: ScoreEntry) -> Bool {
        return lhs.id == rhs.id
    }
//    init(sequence:Int) {
//        self.sequence = sequence
//    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func getNotes() -> [Note]? {
        if self is TimeSlice {
            let ts:TimeSlice = self as! TimeSlice
            return ts.notes
        }
        return nil
    }
    
}

class Sampler {
    var sampler:AVAudioUnitSampler = AVAudioUnitSampler()
    var inited = false
    
//    init(sf2File:String) {
//        guard inited==false else {
//            return
//        }
//        inited = true
//        engine.attach(sampler)
//        engine.connect(sampler, to:Score.engine.mainMixerNode, format:Score.engine.mainMixerNode.outputFormat(forBus: 0))
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                //https://www.rockhoppertech.com/blog/the-great-avaudiounitsampler-workout/#soundfont
//                if let url = Bundle.main.url(forResource:sf2File, withExtension:"sf2") {
//                    try self.sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), bankLSB: UInt8(kAUSampler_DefaultBankLSB))
//                    Logger.logger.log("loaded SF2 for sampler \(sf2File)")
//                }
//                else {
//                    Logger.logger.reportError("Cant load SF2 for sampler \(sf2File)")
//                }
//                
//            } catch let error {
//                Logger.logger.reportError("Sampler cant load sound bank for sampler \(sf2File)", error)
//            }
//        }
//    }
}

class BarLine : ScoreEntry {
    //let atScoreEnd:Bool
//    init(atScoreEnd:Bool = false) {
//        self.atScoreEnd = atScoreEnd
//    }
}

class Score : ObservableObject {
    let id = UUID()
    var timeSignature:TimeSignature
    let ledgerLineCount = 3//4 is required to represent low E

    @Published var key:Key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
    @Published var showNotes = true
    @Published var showFootnotes = false
    @Published var hiddenStaffNo:Int?
    @Published var studentResponseCorrect:Bool? = nil

    var staff:[Staff] = []
    
    var minorScaleType = Scale.MinorType.natural
    var tempo:Float = 75 //BPM, 75 = andante
    static let maxTempo:Float = 200
    static let minTempo:Float = 30
    static let midTempo:Float = Score.minTempo + (Score.maxTempo - Score.minTempo) / 2.0
    static let slowTempo:Float = Score.minTempo + (Score.maxTempo - Score.minTempo) / 4.0

    var staffLineCount:Int = 0
    static var accSharp = "\u{266f}"
    static var accNatural = "\u{266e}"
    static var accFlat = "\u{266d}"
    var scoreEntries:[ScoreEntry] = []
    var label:String? = nil
    
    init(timeSignature:TimeSignature, lines:Int) {
        self.timeSignature = timeSignature
        staffLineCount = lines + (2*ledgerLineCount)
        //print("----Score init", self.id)
        //engine.attach(reverb)
        //reverb.loadFactoryPreset(.largeHall2)
        //reverb.loadFactoryPreset(
        //reverb.wetDryMix = 50

        // Connect the nodes.
        //engine.connect(sampler, to: reverb, format: nil)
        //engine.connect(reverb, to: engine.mainMixerNode, format:engine.mainMixerNode.outputFormat(forBus: 0))
        //print("\n   ==Score created:", self.id)
    }
    
    func setHiddenStaff(num:Int?) {
        DispatchQueue.main.async {
            self.hiddenStaffNo = num
            //print("Score set hidden", self.id, self.hiddenStaffNo)
            for staff in self.staff {
                staff.update()
            }
        }
    }
    
    func setStudentResponse(way:Bool?) {
        DispatchQueue.main.async {
            self.studentResponseCorrect = way
        }
    }

    func getLastTimeSlice() -> TimeSlice? {
        var ts:TimeSlice?
        for index in stride(from: scoreEntries.count - 1, through: 0, by: -1) {
            let element = scoreEntries[index]
            if element is TimeSlice {
                ts = element as! TimeSlice
                break
            }
        }
        return ts
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
        //print("----Score add Timeslice", self.id)
        let ts = TimeSlice(score: self)
        ts.sequence = self.scoreEntries.count
        self.scoreEntries.append(ts)
        return ts
    }
    
    func addBarLine() { //atScoreEnd:Bool? = false) {
//        var barLine:BarLine?
//        if let atScoreEnd = atScoreEnd {
//            barLine = (BarLine(atScoreEnd: atScoreEnd))
//        }
//        else {
//            barLine = BarLine(atScoreEnd: false)
//        }
        let barLine = BarLine()
        barLine.sequence = self.scoreEntries.count
        self.scoreEntries.append(barLine)
    }

    func clear() {
        self.scoreEntries = []
        for staff in staff  {
            staff.clear()
        }
    }
    
    func addStemCharaceteristics() {
        var ctr = 0
        var underBeam = false
        var previousNote:Note? = nil

        for entry in self.scoreEntries {
            if entry is TimeSlice {
                let ts = (entry as! TimeSlice)
                if ts.notes.count == 0 {
                    continue
                }
                let note = ts.notes[0]
                note.beamType = .none
                note.sequence = ctr
                note.stemLength = 3.5
                if note.value == Note.VALUE_QUAVER {
                    if !underBeam {
                        note.beamType = .start
                        underBeam = true
                    }
                    else {
                        note.beamType = .middle
                    }
                }
                else {
                    if underBeam {
                        if let previous = previousNote {
                            if previous.value == Note.VALUE_QUAVER {
                                previous.beamType = .end
                            }
                        }
                        underBeam = false
                    }
                }
                previousNote = note
                ctr += 1
                //print("  ===Score", note.sequence, note.midiNumber, note.beamType)
            }
        }
        if underBeam {
            if let previous = previousNote {
                if previous.value == Note.VALUE_QUAVER {
                    previous.beamType = .end
                }
            }
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
