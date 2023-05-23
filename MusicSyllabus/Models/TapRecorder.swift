import SwiftUI
import CoreData
import AVFoundation

class TapRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, ObservableObject {
    static let shared = TapRecorder()
    var tapTimes:[Double] = []
    var tapValues:[Double] = []
    @Published var status:String = ""
    
    func setStatus(_ msg:String) {
        DispatchQueue.main.async {
            self.status = msg
        }
    }
    
    func startRecording()  {
        print("TapRecorder::started rec")
        self.tapValues = []
        self.tapTimes = []
    }
    
    func makeTap()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        //print(dateString)
        self.tapTimes.append(date.timeIntervalSince1970)
    }

    func stopRecording() {
        tapValues = []
        var last:Double? = nil
        for t in tapTimes {
            var diff = 0.0
            if last != nil {
                diff = (t - last!)
            }
            print(String(format: "%.10f", t), "\t", String(format: "%.4f", diff))
            if last != nil {
                tapValues.append(diff)
            }
            last = t

        }
        print("TapRecorder::ended rec", tapValues.count)
    }

    func playRecording() {
        print("TapRecorder::play", tapValues.count)
    }

    func roundNoteValue(inValue:Double) -> Double? {
        if inValue < 0.3 {
            return nil
        }
        if inValue < 0.8 {
            return 0.5
        }
        if inValue < 1.4 {
            return 1.0
        }
        if inValue < 2.4 {
            return 2.0
        }
        return nil
    }
    
    func makeScore(inputScore:Score) -> Score {
        var outputScore = Score(timeSignature: inputScore.timeSignature, lines: 1)
        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
        outputScore.setStaff(num: 0, staff: staff)
        var ctr = 0
        var totalValue = 0.0
        
        for n in self.tapValues {
            
            let noteValue = roundNoteValue(inValue: n)
            if let noteValue = noteValue {
                if totalValue >= Double(inputScore.timeSignature.top) {
                    print("  Barline1", totalValue, outputScore.scoreEntries.count)

                    outputScore.addBarLine()
                    totalValue = 0.0
                    print("  Barline2", totalValue, outputScore.scoreEntries.count)
                }
                let timeSlice = outputScore.addTimeSlice()

                let note = Note(num: 0, value: noteValue)
                note.isOnlyRhythmNote = true
//                if ctr % 3 == 1 {
//                    note.noteTag = .inError
//                }
                timeSlice.addNote(n: note)
                totalValue += noteValue
                print("  Note value", note.value, totalValue, outputScore.scoreEntries.count)
            }
            ctr += 1
        }
        return outputScore
    }
//
//    func analyseAddUserRhythm(inputScore:Score) -> Score {
//        var outputScore = Score(timeSignature: inputScore.timeSignature, lines: 1)
//        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
//        outputScore.setStaff(num: 0, staff: staff)
//        print("TapRecorder make score-")
//        var ctr = 0
//        for e in inputScore.scoreEntries {
//            if e is TimeSlice {
//                let ts = e as! TimeSlice
//                let userNote = ts.notes[0]
//                let timeSlice = outputScore.addTimeSlice()
//                let note = Note(num: 0, value: userNote.value)
//                note.isOnlyRhythmNote = true
////                if ctr % 3 == 1 {
////                    note.noteTag = .inError
////                }
//                timeSlice.addNote(n: note)
//
//                ctr += 1
//            }
//            if e is BarLine {
//                outputScore.addBarLine()
//
//            }
//        }
//        return outputScore
//    }
    
    func analyseRhythm(timeSignatue:TimeSignature, inputScore:Score) -> Score {
        //print("analyseRhythm", self.tapValues)
//        for value in self.tapValues {
//            print(String(format: "%.1f", value))
//        }
        //let outScore = self.analyseAddUserRhythm(inputScore: inputScore)
        let outScore = self.makeScore(inputScore: inputScore)
        return outScore
    }
}

