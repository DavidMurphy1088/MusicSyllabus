import SwiftUI
import CoreData

struct IntervalsView: View {
    @State var score:Score
    
    init() {
        score = Score(timeSignature: TimeSignature(), lines: 5)
        //score.showNotes = false
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        score.setStaff(num: 0, staff: staff)
        var n = Note.MIDDLE_C +  5 //Note.OCTAVE - 3 //A
        for i in 0...7 {
            var ts = score.addTimeSlice()
            ts.addNote(n: Note(num: n+i))
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                ScoreView(score: score).padding()
            }
        }
    }
}

