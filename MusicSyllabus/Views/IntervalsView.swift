import SwiftUI
import CoreData


struct IntervalsView: View {
    @State var score:Score
    
    init() {
        score = Score()
        let staff = Staff(score: score, type: .treble, staffNum: 0)
        score.setStaff(num: 0, staff: staff)
        //let ts = score.addTimeSlice()
        //ts.addNote(n: note)
    }
    
    var body: some View {
        VStack {
            HStack {
                
                ScoreView(score: score).padding()
            }

        }
    }
}

