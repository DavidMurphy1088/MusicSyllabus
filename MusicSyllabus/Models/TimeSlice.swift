import Foundation

class TimeSlice : ScoreEntry {//}, Hashable   { //}: ObservableObject,  {
    var score:Score?
    var note:[Note]
    var footnote:String?
    var barLine:Int = 0
    
    private static var idIndex = 0
    
    init(score:Score?) {
        self.score = score
        self.note = []
        TimeSlice.idIndex += 1
    }
    
    func addNote(n:Note) {
        self.note.append(n)
        if let score = score {
            score.updateStaffs()
            score.addStemCharaceteristics()
        }
    }
    
    func addChord(c:Chord) {
        for n in c.notes {
            self.note.append(n)
        }
        if let score = score {
            score.updateStaffs()
        }
    }
    
    static func == (lhs: TimeSlice, rhs: TimeSlice) -> Bool {
        return lhs.id == rhs.id
    }
}
