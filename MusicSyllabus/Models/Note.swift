import Foundation

enum AccidentalType {
    case sharp
    case flat
}

enum HandType {
    case left
    case right
}

enum BeamType {
    case none
    case start
    case middle
    case end
}

class Note : Hashable, Comparable, ObservableObject {
    let id = UUID()
    var midiNumber:Int
    var staff:Int
    var value:Double = Note.VALUE_QUARTER
    var isOnlyRhythmNote = false
    var stemUp:Bool
    var beamType:BeamType = .none
    var stemLength:Double = 0 //measured in number of staff lines
    var sequence:Int = 0 //the note's sequence position 

    @Published var hilite = false
    
    static let MIDDLE_C = 60 //Midi pitch for C4
    static let OCTAVE = 12
    static let noteNames:[Character] = ["A", "B", "C", "D", "E", "F", "G"]
    
    static let VALUE_QUAVER = 0.5
    static let VALUE_QUARTER = 1.0
    static let VALUE_HALF = 2.0
    static let VALUE_WHOLE = 4.0

    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNumber == rhs.midiNumber
    }
    static func < (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNumber < rhs.midiNumber
    }
    
    static func isSameNote(note1:Int, note2:Int) -> Bool {
        return (note1 % 12) == (note2 % 12)
    }
    
    init(num:Int, value:Double? = 0, staff:Int = 0) {
        self.midiNumber = num
        self.staff = staff
        self.value = value!
        self.stemUp = true
    }
    
    func setHilite(hilite: Bool) {
        DispatchQueue.main.async {
            self.hilite = hilite
        }
    }
    
    func setIsOnlyRhythm(way: Bool) {
        self.isOnlyRhythmNote = way
        if self.isOnlyRhythmNote {
            self.midiNumber = Note.MIDDLE_C + Note.OCTAVE - 1
        }
        
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(midiNumber)
    }
    
    static func staffNoteName(idx:Int) -> Character {
        if idx >= 0 {
            return self.noteNames[idx % noteNames.count]
        }
        else {
            return self.noteNames[noteNames.count - (abs(idx) % noteNames.count)]
        }
    }

    static func getAllOctaves(note:Int) -> [Int] {
        var notes:[Int] = []
        for n in 0...88 {
            if note >= n {
                if (note - n) % 12 == 0 {
                    notes.append(n)
                }
            }
            else {
                if (n - note) % 12 == 0 {
                    notes.append(n)
                }
            }
        }
        return notes
    }
    
    static func getClosestOctave(note:Int, toPitch:Int, onlyHigher: Bool = false) -> Int {
        let pitches = Note.getAllOctaves(note: note)
        var closest:Int = note
        var minDist:Int?
        for p in pitches {
            if onlyHigher {
                if p < toPitch {
                    continue
                }
            }
            let dist = abs(p - toPitch)
            if minDist == nil || dist < minDist! {
                minDist = dist
                closest = p
            }
        }
        return closest
    }
}
