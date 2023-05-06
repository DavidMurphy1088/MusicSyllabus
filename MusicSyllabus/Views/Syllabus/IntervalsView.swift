import SwiftUI
import CoreData

struct IntervalsView:View {
    @State var exampleNum:Int
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 5)
    
    init(exampleNum:Int) {
        self.exampleNum = exampleNum

        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        score.setStaff(num: 0, staff: staff)
        var n = Note.MIDDLE_C +  7 //Note.OCTAVE - 3 //A
        for i in 0...5 {
            var ts = score.addTimeSlice()
            let value = i == 0 ? 2: 4
            ts.addNote(n: Note(num: n+i, value: value))
        }
    }
    
    var body: some View {
        VStack {
            Text("this is example \(exampleNum)")
            HStack {
                ScoreView(score: score).padding()
            }
        }
    }
}

