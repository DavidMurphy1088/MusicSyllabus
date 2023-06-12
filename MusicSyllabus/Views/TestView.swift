import SwiftUI
import CoreData
import AVFoundation
import Accelerate

struct TestView: View {
    var score1:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    var score2:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)
    let ap = AudioPlayerTest()
    //let tuner = TunerView()
    let tuner = TunerConductor()
    
    //let dataPoints: [CGFloat] = [0, 20, 10, 30, 25, 40, 30, 50] // Example data points
    @ObservedObject var test = NoteOnsetAnalyser()
    
    //typically 10-50 milliseconds.
    @State private var segmentLengthSecondsMilliSec: Double = 0.5
    @State private var noteOnsetSliceWidthPercent: Double = 0.005
    @State private var FFTWindowSize: Double = 4096.0
    //@State private var amplitudeFilter: Double = 0.1
    @State private var amplitudeFilter: Double = 0.4

    init () {
        let data = ExampleData.shared
        let exampleData = data.get(contentSection: ContentSection(parent: nil, type: .example, name: "test"))

        let staff1 = Staff(score: score1, type: .treble, staffNum: 0, linesInStaff: 5)
        let staff1B = Staff(score: score1, type: .bass, staffNum: 1, linesInStaff: 5)

        let staff2 = Staff(score: score2, type: .treble, staffNum: 0, linesInStaff: 5)
        
        self.score1.setStaff(num: 0, staff: staff1)
        self.score1.setStaff(num: 1, staff: staff1B)

        self.score2.setStaff(num: 0, staff: staff2)
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = self.score1.addTimeSlice()
                    let note = entry as! Note
                    if note.midiNumber == Note.MIDDLE_C {
                        note.staffNum = 1
                    }
                    note.isOnlyRhythmNote = true
                    timeSlice.addNote(n: note)
                    
//                    var timeSlice2 = self.score2.addTimeSlice()
//                    var n = Note(num:72, value: note.value)
//                    //n.isOnlyRhythmNote = true
//                    timeSlice2.addNote(n: n)

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

//        var ts = self.score1.addTimeSlice()
//        ts.addNote(n: Note(num: 48, value: 3.0))
//        ts.addNote(n: Note(num: 52, value: 3.0))
//        ts.addNote(n: Note(num: 55, value: 3.0))

        for i in 0...8 {
            var timeSlice2 = self.score2.addTimeSlice()
            var n = Note(num:67 + (i % 4)*2, value: i % 3 != 0 ? 0.5 : 1.0)
            //n.isOnlyRhythmNote = true
            timeSlice2.addNote(n: n)
        }

      //score1.addStemCharaceteristics()
        //score2.addStemCharaceteristics()
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Button(action: {
                        test.processFile(fileName: "Example 1", segmentLengthSecondsMilliSec: segmentLengthSecondsMilliSec)
                    }) {
                        Text("Segment Audio")
                    }
                    .padding()
                    
                    Button(action: {
                        test.detectNotes(segmentAverages: test.segmentAverages, noteOnsetSliceWidthPercent: noteOnsetSliceWidthPercent, segmentLengthSecondsMilliSec: segmentLengthSecondsMilliSec, FFTWindowSize:Int(FFTWindowSize))
                    }) {
                        Text("Detect Notes")
                    }
                    .padding()
                    
                    Button(action: {
                        tuner.run(amplitudeFilter: amplitudeFilter)
                    }) {
                        Text("TunerTest")
                    }
                    .padding()
                }
                
                HStack {
                    Text("Segment Length:\(String(format: "%.2f", self.segmentLengthSecondsMilliSec)) ms")
                    .padding()
                    Slider(value: self.$segmentLengthSecondsMilliSec, in: 0.05...2.0)
                }
                HStack {
                    Text("NoteOnset slice size:\(String(format: "%.3f", self.noteOnsetSliceWidthPercent)) ms")
                    Slider(value: self.$noteOnsetSliceWidthPercent, in: 0.001...0.020)
                }
                .padding()
                HStack {
                    Text("FFT Window:\(String(format: "%.0f", self.FFTWindowSize)) ms")
                    Slider(value: self.$FFTWindowSize, in: 2000.0...100000.0)
                }
                .padding()
                HStack {
                    Text("amplitudeFilter:\(String(format: "%.2f", self.amplitudeFilter))")
                    Slider(value: self.$amplitudeFilter, in: 0.1...10.0)
                }
                .padding()

                
                
                Text("Status:\(test.status)")
                .padding()                

                TunerView()
//                LineChartView(dataPoints: test.segmentAverages)
//                    .border(Color.indigo)
//                    .padding()
                LineChartView(dataPoints: test.fourierValues)
                    .border(Color.indigo)
                    //.frame(maxWidth: .infinity)
                    .frame(width: geo.size.width, height: geo.size.height / 3.0)
                    //.padding()
                    //.frame(maxWidth: .infinity)
                    //.frame(height: geo.size.height / 0.5)
//                LineChartView(dataPoints: test.fourierTransformValues)
//                    .border(Color.green)
//                    .frame(width: geo.size.width, height: geo.size.height / 3.0)
//                    //.padding()
//                    //.frame(height: geo.size.height / 0.5)
            }
        }
    }
}

