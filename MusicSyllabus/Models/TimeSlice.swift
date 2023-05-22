import Foundation

class TimeSlice : ScoreEntry {
    var score:Score?
    var notes:[Note]
    var footnote:String?
    var barLine:Int = 0
    var tag:String?
    
    private static var idIndex = 0
    
    init(score:Score?) {
        self.score = score
        self.notes = []
        TimeSlice.idIndex += 1
    }
    
    func addNote(n:Note) {
        self.notes.append(n)
        if let score = score {
            score.updateStaffs()
//            if n.midiNumber < 60 {
//
//            }
            score.addStemCharaceteristics()
        }
    }
    
    func addChord(c:Chord) {
        for n in c.notes {
            self.notes.append(n)
        }
        if let score = score {
            score.updateStaffs()
        }
    }
    
    static func == (lhs: TimeSlice, rhs: TimeSlice) -> Bool {
        return lhs.id == rhs.id
    }
}
