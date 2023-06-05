import SwiftUI
import CoreData

struct TestView: View {
    var score1:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    //var score2:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)

    init () {
        let data = ExampleData.shared
        let exampleData = data.get(contentSection: ContentSection(parent: nil, type: .example, name: "test"))

        let staff1 = Staff(score: score1, type: .treble, staffNum: 0, linesInStaff: 5)
        //let staff1B = Staff(score: score1, type: .bass, staffNum: 1, linesInStaff: 5)

        //let staff2 = Staff(score: score2, type: .treble, staffNum: 0, linesInStaff: 5)
        
        self.score1.setStaff(num: 0, staff: staff1)
        //self.score1.setStaff(num: 1, staff: staff1B)

        //self.score2.setStaff(num: 0, staff: staff2)
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = self.score1.addTimeSlice()
                    let note = entry as! Note
                    if note.midiNumber == Note.MIDDLE_C {
                        note.staffNum = 1
                    }
                    //note.isOnlyRhythmNote = true
                    timeSlice.addNote(n: note)
                    
                }
                if entry is TimeSignature {
                    let ts = entry as! TimeSignature
                    score1.timeSignature = ts
                }
                if entry is BarLine {
                    //let bl = entry as! BarLine
                    score1.addBarLine()
                }
                if score1.scoreEntries.count > 200 {
                    break
                }
            }
        }
        
//        var timeSlice2 = self.score2.addTimeSlice()
//        timeSlice2.addNote(n: Note(num:76, value: 1.0))
//        timeSlice2 = self.score2.addTimeSlice()
//        timeSlice2.addNote(n: Note(num:76, value: 0.5))
//        timeSlice2 = self.score2.addTimeSlice()
//        timeSlice2.addNote(n: Note(num:77, value: 0.5))
//        timeSlice2 = self.score2.addTimeSlice()
//        timeSlice2.addNote(n: Note(num:79, value: 1.0))
//        timeSlice2 = self.score2.addTimeSlice()
//        timeSlice2.addNote(n: Note(num:81, value: 1.0))

        score1.addStemCharaceteristics()
        //score2.addStemCharaceteristics()
    }
    
    var body: some View {
        //GeometryReader { geometry in
        VStack {
            Text("--Test View--")
            MetronomeView()
            ScoreView(score: score1)
            Text(" ")
            //ScoreView(score: score2)
        }

    }
}

