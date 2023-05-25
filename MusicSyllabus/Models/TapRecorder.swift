import SwiftUI
import CoreData
import AVFoundation

class TapRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, ObservableObject {
    static let shared = TapRecorder()
    var tapTimes:[Double] = []
    var tapValues:[Double] = []
    @Published var status:String = ""
    //let tapSoundEffect = SoundEffect(systemSound: .click)
    
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
        self.tapTimes.append(date.timeIntervalSince1970)
        //AudioServicesPlayAlertSound(SystemSoundID(1104))
        AudioServicesPlaySystemSound(SystemSoundID(1104))
    }

    func stopRecording() {
        self.tapTimes.append(Date().timeIntervalSince1970) // record value of last tap made
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
        return 4.0
    }
    
    func makeScoreNew(timeSignature:TimeSignature) -> Score {
        var outputScore = Score(timeSignature: timeSignature, lines: 1)
        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
        outputScore.setStaff(num: 0, staff: staff)
        var ctr = 0
        var totalValue = 0.0
        
        for n in self.tapValues {
            
            let noteValue = roundNoteValue(inValue: n)
            if let noteValue = noteValue {
                if totalValue >= Double(timeSignature.top) {
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
                //print("  Note value", note.value, totalValue, outputScore.scoreEntries.count)
            }
            ctr += 1
        }
        return outputScore
    }
    
    func analyseDifferencesNew(questionScore:Score, userScore:Score) -> Score {
        
        class NoteMatch {
            var note:Note
            var playTime:Double
            var matchQuestionNote:Note?
            
            init(note:Note, playTime:Double) {
                self.note = note
                self.matchQuestionNote = nil
                self.playTime = playTime
            }
        }
        
        // build each student note's play time
        // for each student note track the question note that it matches to
        var userNoteMatches:[NoteMatch] = []
        var playTime = 0.0
        for entry in userScore.scoreEntries {
            guard let notes = entry.getNotes() else {
                continue
            }
            let note = notes[0]
            userNoteMatches.append(NoteMatch(note: note, playTime: playTime))
            print("user note:", note.midiNumber, note.value, "\tat", playTime)
            playTime += note.value
        }
        
        // for each question note find he best student note
        let score = Score(timeSignature: questionScore.timeSignature, lines: questionScore.staffLineCount)
        playTime = 0.0
        var matches:[(Note, Double, Note?)] = []
        
        for entry in questionScore.scoreEntries {
            if entry is TimeSlice {
                let ts = entry as! TimeSlice
                let questionNote = ts.notes[0]
                
                var minDiff = Double.infinity
                var bestFit:Note?
                
                // find the closest user note for this question note
                for i in 0..<userNoteMatches.count {
                    if userNoteMatches[i].matchQuestionNote != nil {
                        continue
                    }
                    let diff = abs(playTime - userNoteMatches[i].playTime)
                    if diff < minDiff {
                        minDiff = diff
                        bestFit = userNoteMatches[i].note
                    }
                }
                matches.append((questionNote, playTime, bestFit))
                playTime += questionNote.value
            }
        }
        
        playTime = 0
        for match in matches {
            print("match time:", playTime, match.1, "\tQuestion", match.0.value, "\tStudent note seq,value", match.2?.sequence,  match.2?.value)
            playTime += match.0.value
        }
        return score
    }
    
//    func analyseRhythmNew (timeSignatue:TimeSignature, questionScore:Score) -> Score {
//        let userScore = self.makeScore(timeSignature: questionScore.timeSignature)
//        let score = analyseDifferences(questionScore:questionScore, userScore: userScore)
//        return score
//    }
//
//    func analyseRhythm(timeSignatue:TimeSignature, questionScore:Score) -> Score {
//            let userScore = self.makeScore(timeSignature: questionScore.timeSignature)
//            let score = analyseDifferences(questionScore:questionScore, userScore: userScore)
//            return score
//    }
    
    
    func makeScore(questionScore:Score) -> Score {
        let outputScore = Score(timeSignature: questionScore.timeSignature, lines: 1)
        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
        outputScore.setStaff(num: 0, staff: staff)
        var ctr = 0
        //var totalValue = 0.0
        
        let lastQuestionTimeslice = questionScore.getLastTimeSlice()
        var lastQuestionNote:Note?
        if let ts = lastQuestionTimeslice {
            if ts.notes.count > 0 {
                lastQuestionNote = ts.notes[0]
            }
        }
        
        var totalValue = 0.0
        
        for i in 0..<self.tapValues.count {
            let n = self.tapValues[i]
            let noteValue = roundNoteValue(inValue: n)
            if let noteValue = noteValue {
                if totalValue >= Double(questionScore.timeSignature.top) {
                    print("  Barline1", totalValue, outputScore.scoreEntries.count)
                    outputScore.addBarLine()
                    totalValue = 0.0
                    print("  Barline2", totalValue, outputScore.scoreEntries.count)
                }
                let timeSlice = outputScore.addTimeSlice()

                var value = noteValue
                if i == self.tapValues.count - 1 {
                    //The last tap value is when the studnet endeded the recording. So instead, let the last note value be the last question note value
                    if lastQuestionNote != nil {
                        value = lastQuestionNote!.value
                    }
                }
                let note = Note(num: 0, value: value)
                note.isOnlyRhythmNote = true
//                if ctr % 3 == 1 {
//                    note.noteTag = .inError
//                }
                timeSlice.addNote(n: note)
                totalValue += noteValue
                //print("  Note value", note.value, totalValue, outputScore.scoreEntries.count)
            }
            ctr += 1
        }
        
        return outputScore
    }

    func analyseRhythm(timeSignatue:TimeSignature, inputScore:Score) -> Score {
        //print("analyseRhythm", self.tapValues)
        //        for value in self.tapValues {
        //            print(String(format: "%.1f", value))
        //        }
        //let outScore = self.analyseAddUserRhythm(inputScore: inputScore)
        let outScore = self.makeScore(questionScore: inputScore)
        return outScore
    }
}


