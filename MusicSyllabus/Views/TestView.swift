import SwiftUI

struct TestView: View {
    var score:Score
    @ObservedObject var staff:Staff
    @ObservedObject var ts:TimeSlice
    
    init() {
        score = Score(timeSignature: TimeSignature(top: 4, bottom: 4), linesPerStaff: 5)
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        self.score.setStaff(num: 0, staff: staff)
        let ts = score.addTimeSlice()
        ts.addNote(n: Note(num: 72))
        self.ts = ts
        self.staff = staff
    }
    
    var body: some View {
        VStack {
            Text("test")
            //ToolsView(score: score)
            //ScoreView(score: score).padding()
            
            StaffView(score: score, staff: staff, staffLayoutSize: StaffLayoutSize(lineSpacing:20)).padding().border(Color.blue)
            
            //Text("Ts:: \(tagText())")
            
            StaffNotesView(score: score, staff: staff, lineSpacing: StaffLayoutSize(lineSpacing: 20))
                //.border(Color.indigo)
                .frame(width: 5 * Double(ts.notesLength ?? 0) + 200)
            
            Button(action: {
                ts.addNote(n: Note(num: 67))
                print("Button tapped", ts.getNotes()?.count)
                for family in UIFont.familyNames {
                    for font in UIFont.fontNames(forFamilyName: family) {
                        print(font)
                    }
                }
            }) {
                Text("Addnote").padding()
            }
            Spacer()
        }
    }
}

