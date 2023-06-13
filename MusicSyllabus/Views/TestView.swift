import SwiftUI
import CoreData
import AVFoundation
import Accelerate

struct TestView: View {
    var score1:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    var score2:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)
    let ap = AudioPlayerTest()
    let test = Test()
    //let tuner = TunerView()
    let tuner = TunerConductor()
    
    @State private var selectedNumber = 0
    let numbers = Array(1...8)
    
    @ObservedObject var noteOnsetAnalyser = NoteOnsetAnalyser()
    
    //typically 10-50 milliseconds.
    @State private var segmentLengthSecondsMilliSec: Double = 0.5
    @State private var noteOnsetSliceWidthPercent: Double = 0.005
    @State private var FFTWindowSize: Double = 4096.0
    @State private var FFTWindowOffset: Double = 1024.0
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
    func arrayToFloat(_ doubleArray: [Double]) -> [Float] {
        return doubleArray.map { Float($0) }
    }
 
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Button(action: {
                        //noteOnsetAnalyser.makeSegmentAverages(fileName: "Example \(self.selectedNumber)", segmentLengthSecondsMilliSec:segmentLengthSecondsMilliSec)
                        noteOnsetAnalyser.makeSegmentAverages(fileName: "Example 7_sequenced", segmentLengthSecondsMilliSec:segmentLengthSecondsMilliSec)
                    }) {
                        Text("Make Segment Averages")
                    }
                    .padding()
                    
                    Button(action: {
                        noteOnsetAnalyser.detectNoteOnsets(segmentAverages: noteOnsetAnalyser.segmentAverages, noteOnsetSliceWidthPercent: noteOnsetSliceWidthPercent, segmentLengthSecondsMilliSec: segmentLengthSecondsMilliSec,
                                                           FFTFrameSize:Int(FFTWindowSize),
                                                           FFTFrameOffset: Int(FFTWindowOffset))
                    }) {
                        Text("Detect Notes")
                    }
                    .padding()
                    
                    Button(action: {
                        //tuner.run(amplitudeFilter: amplitudeFilter)
                        
                        //noteOnsetAnalyser.makeHammedAudioFile(fileName: "Example 1", outputName: "Example_1_Hammed")
                    }) {
                        Text("Make Hammed File")
                    }
                    .padding()

                    Button(action: {
                        //tuner.run(amplitudeFilter: amplitudeFilter)
                        test.measurePitch(fileName: "Example 5")
                    }) {
                        Text("Test")
                    }
                    .padding()
                }
                
//                Picker("Select Number", selection: $selectedNumber) {
//                    ForEach(0..<numbers.count) { index in
//                        Text("\(numbers[index])")
//                    }
//                }

                
                //Text("Status:\(noteOnsetAnalyser.status)").padding()

                //TunerView()
                
                //================ smoothing (segments)
                
                HStack {
                    Text("Segment Average Length:\(String(format: "%.2f", self.segmentLengthSecondsMilliSec)) ms")
                    Slider(value: self.$segmentLengthSecondsMilliSec, in: 0.05...2.0)
                }
                .padding(.horizontal)

                LineChartView(dataPoints: noteOnsetAnalyser.segmentAverages, title: "Sample Averages")
                    .border(Color.indigo)
                    .frame(height: geo.size.height / 4.0)
                    .padding(.horizontal)
                
                //================ rhythm and pitch
                
                HStack {
                    Text("NoteOnset slice size:\(String(format: "%.3f", self.noteOnsetSliceWidthPercent)) ms")
                    Slider(value: self.$noteOnsetSliceWidthPercent, in: 0.001...0.020)
                }
                .padding(.horizontal)

                HStack {
                    Text("FFT Frame Size:\(String(format: "%.0f", self.FFTWindowSize))")
                    Slider(value: self.$FFTWindowSize, in: 200.0...10000.0)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("FFT Frame Offset:\(String(format: "%.2f", self.FFTWindowOffset))")
                    Slider(value: self.$FFTWindowOffset, in: -10000.0...10000.0)
                }
                .padding(.horizontal)

//                HStack {
//                    LineChartView(dataPoints: noteOnsetAnalyser.pitchInputValues, title: "Frames into FFT")
//                        .border(Color.indigo)
//                        .frame(height: geo.size.height / 4.0)
//                        .padding(.horizontal)
//                    Text(" ")
//                }
                
                HStack {
                    LineChartView(dataPoints: noteOnsetAnalyser.pitchInputValuesWindowed, title: "Windowed Frames into FFT")
                        .border(Color.indigo)
                        .frame(height: geo.size.height / 4.0)
                        .padding(.horizontal)
                    Text(" ")
                }

                LineChartView(dataPoints: noteOnsetAnalyser.pitchOutputValues, title: "FFT Output")
                    .border(Color.green)
                    .frame(height: geo.size.height / 6.0)
                    .padding(.horizontal)

            }
        }
    }
}

