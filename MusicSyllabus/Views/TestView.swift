import SwiftUI
import CoreData

struct TestView: View {
    var score:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)

    init () {
        let data = ExampleData.shared
        let exampleData = data.get(contentSection: ContentSection(parent: nil, type: .example, name: "test"))

        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        self.score.setStaff(num: 0, staff: staff)
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = self.score.addTimeSlice()
                    let note = entry as! Note
                    note.isOnlyRhythmNote = true
                    timeSlice.addNote(n: note)
                }
                if entry is TimeSignature {
                    let ts = entry as! TimeSignature
                    score.timeSignature = ts
                }
                if entry is BarLine {
                    //let bl = entry as! BarLine
                    score.addBarLine()
                }
                if score.scoreEntries.count > 200 {
                    break
                }
            }
        }
        score.addStemCharaceteristics()
    }
    
    var body: some View {
        //GeometryReader { geometry in
        VStack {
            Text("--Test View--")
            ScoreView(score: score)
        }
        //}
    }
}
