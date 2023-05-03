import Foundation

class TimeSlice : Hashable  { //}: ObservableObject,  {
    var score:Score
    var note:[Note]
    var footnote:String?
    
    private static var idIndex = 0
    private var id = 0
    
    init(score:Score) {
        self.score = score
        self.note = []
        self.id = TimeSlice.idIndex
        TimeSlice.idIndex += 1
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note)
    }
    
    func addNote(n:Note) {
        self.note.append(n)
        score.updateStaffs()
    }
    
    func addChord(c:Chord) {
        for n in c.notes {
            self.note.append(n)
        }
        score.updateStaffs()
    }

    static func == (lhs: TimeSlice, rhs: TimeSlice) -> Bool {
        return lhs.id == rhs.id
    }
}
