import Foundation
import AVKit
import AVFoundation

class ScoreEntry : Hashable {
    let id = UUID()
    var sequence:Int = 0
    static func == (lhs: ScoreEntry, rhs: ScoreEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
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

class BarLine : ScoreEntry {

}

class StudentFeedback { //}: ObservableObject {
    var correct:Bool = false
    var feedback:String? = nil
    var tempo:Int? = nil
}

class Score : ObservableObject {
    let id = UUID()
    var timeSignature:TimeSignature
    let ledgerLineCount = 3//4 is required to represent low E
    
    @Published var key:Key = Key(type: Key.KeyType.major, keySig: KeySignature(type: AccidentalType.sharp, count: 0))
    @Published var showNotes = true
    @Published var showFootnotes = false
    @Published var hiddenStaffNo:Int?
    @Published var studentFeedback:StudentFeedback? = nil
    
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
    }
    
    func getAllTimeSlices() -> [TimeSlice] {
        var result:[TimeSlice] = []
        for scoreEntry in self.scoreEntries {
            if scoreEntry is TimeSlice {
                let ts = scoreEntry as! TimeSlice
                result.append(ts)
            }
        }
        return result
    }
    
    //return the first entry and timeslice index of where the scores differ
    func GetFirstDifferentTimeSlice(compareScore:Score) -> Int? {
        //let compareEntries = compareScore.scoreEntries
        var result:Int? = nil
        var scoreCtr = 0

        let scoreTimeSlices = self.getAllTimeSlices()
        let compareTimeSlices = compareScore.getAllTimeSlices()

        for scoreTimeSlice in scoreTimeSlices {

            if compareTimeSlices.count <= scoreCtr {
                result = scoreCtr
                break
            }
            
            let compareEntry = compareTimeSlices[scoreCtr]
            let compareNotes = compareEntry.getNotes()
            let scoreNotes = scoreTimeSlice.getNotes()

            if compareNotes == nil || scoreNotes == nil {
                result = scoreCtr
                break
            }
            if compareNotes?.count == 0 || scoreNotes!.count == 0 {
                result = scoreCtr
                break
            }

            if scoreCtr == scoreTimeSlices.count - 1 {
                //last note just has to be semibreve (1/2 note) or longer, any other note must be an exact note value match
                if compareNotes![0].value < Note.VALUE_HALF {
                    result = scoreCtr
                    break
                }
                else {
                    compareNotes![0].value = scoreNotes![0].value
                }
            }
            else {
                if scoreNotes![0].value != compareNotes![0].value {
                    result = scoreCtr
                    break
                }
            }
            scoreCtr += 1
        }
        print("---------------------> Score diff", result ?? 0)
        return result
    }
    
    func setHiddenStaff(num:Int?) {
        DispatchQueue.main.async {
            self.hiddenStaffNo = num
            for staff in self.staff {
                staff.update()
            }
        }
    }
    
    func setStudentFeedback(studentFeedack:StudentFeedback? = nil) {
        DispatchQueue.main.async {
            self.studentFeedback = studentFeedack
            print("===============> Set Student feedback ", studentFeedack?.correct, studentFeedack?.feedback)
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
        //if self.scoreEntries.count >= 4 {
        //print("addStemCharaceteristics TEST", self.scoreEntries.count)
        //}
        let timeSlices = self.getAllTimeSlices()
        for timeSlice in timeSlices {
            if timeSlice.notes.count == 0 {
                continue
            }
            let note = timeSlice.notes[0]
            note.beamType = .none
            note.sequence = ctr
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
                    if let beamEndNote = previousNote {
                        if beamEndNote.value == Note.VALUE_QUAVER {
                            beamEndNote.beamType = .end
                        }
                        //update the notes in under the quaver beam with the end note of the beam
                        var idx = ctr - 1
                        while idx >= 0 {
                            let prevNote = timeSlices[idx].notes[0]
                            if prevNote.value != Note.VALUE_QUAVER {
                                break
                            }
                            prevNote.beamEndNote = beamEndNote
                            idx = idx - 1
                        }
     
                    }
                    underBeam = false
                }
            }
            previousNote = note
            ctr += 1
        }
        
//        if underBeam {
//            if let previous = previousNote {
//                if previous.value == Note.VALUE_QUAVER {
//                    previous.beamType = .end
//                }
//            }
//        }
        for ts in timeSlices {
            let note = ts.notes[0]
            //print(note.sequence, "value", note.value, "BeamType", note.beamType, "\tend beam note", note.beamEndNote?.sequence ?? "None")
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
                        usleep(useconds_t(playTempo * 500000))
                    }
                }

            }
        }
    }
}
