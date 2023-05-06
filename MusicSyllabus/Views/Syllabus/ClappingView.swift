import SwiftUI
import CoreData

struct ClappingView:View {
    @State var exampleNum:Int
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 1)
    
    init(exampleNum:Int) {
        self.exampleNum = exampleNum

        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 1)
        score.setStaff(num: 0, staff: staff)
        var n = Note.MIDDLE_C + Note.OCTAVE - 1
        for i in 0..<6 {
            var ts = score.addTimeSlice()
            let value = i%2 == 0 ? 2: 4
            ts.addNote(n: Note(num: n, value: value))
            if value == 2 {
                ts = score.addTimeSlice()
                score.addBarLine()
            }
            
        }
        score.addBarLine()
    }
    
    var body: some View {
        VStack {
            Text("Please clap this written rhythm in simple time. \(exampleNum)")
            HStack {
                ScoreView(score: score).padding()
            }
        }
    }
}

