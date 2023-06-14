import SwiftUI
import CoreData
import AVFoundation

class TapRecorder : NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate, ObservableObject {
    static let shared = TapRecorder()
    var tapTimes:[Double] = []
    var tapValues:[Double] = []
    @Published var status:String = ""
    @Published var enableRecordingLight = false
    var metronome = Metronome.getMetronomeWithStandardSettings()
    
    func setStatus(_ msg:String) {
        DispatchQueue.main.async {
            self.status = msg
        }
    }
    
    func startRecording(metronomeLeadIn:Bool)  {
        self.tapValues = []
        self.tapTimes = []
        if metronomeLeadIn {
            self.enableRecordingLight = false
            //metronome.startTicking(numberOfTicks: timeSignature.top * 2, onDone: endMetronomePrefix)
        }
        else {
            self.enableRecordingLight = true
        }
    }
    
    func endMetronomePrefix() {
        DispatchQueue.main.async {
            self.enableRecordingLight = true
        }
    }
    
    func makeTap()  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = Date()
        self.tapTimes.append(date.timeIntervalSince1970)
        //audioPlayer.play() Audio Player starts the tick too slowly for fast tempos and short value note and therefore throws of the tapping
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
            //print(" tick " + String(format: "%.1f", t), "\t", String(format: "%.2f", diff))
            if last != nil {
                tapValues.append(diff)
            }
            last = t
        }
        print("TapRecorder::stopRecording times", tapValues.count)
    }

    //Return the standard note value for a millisecond duration given the tempo input
    func roundNoteValueToStandardValue(inValue:Double, tempo:Int) -> Double? {
        let inValueAtTempo = (inValue * Double(tempo)) / 60.0
        if inValueAtTempo < 0.3 {
            return nil
        }
        if inValueAtTempo < 0.75 {
            return 0.5
        }
        if inValueAtTempo < 1.5 {
            return 1.0
        }
        if inValueAtTempo < 2.5 {
            return 2.0
        }
        if inValueAtTempo < 3.5 {
            return 3.0
        }
        return 4.0
    }
    
    //make a score of notes and barlines from the tap intervals
    func makeScore(questionScore:Score, tempo:Int) -> Score {
        let outputScore = Score(timeSignature: questionScore.timeSignature, lines: 1)
        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
        outputScore.setStaff(num: 0, staff: staff)
        var ctr = 0
        
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
            let noteValue = roundNoteValueToStandardValue(inValue: n, tempo: tempo)
            if let noteValue = noteValue {
                if totalValue >= Double(questionScore.timeSignature.top) {
                    outputScore.addBarLine()
                    totalValue = 0.0
                }
                let timeSlice = outputScore.addTimeSlice()

                var value = noteValue
                if i == self.tapValues.count - 1 {
//                    //The last tap value is when the studnet endeded the recording. So instead, let the last note value be the last question note value
                    if lastQuestionNote != nil {
                        if value > lastQuestionNote!.getValue(){
                            //the student delayed the end of recording
                            value = lastQuestionNote!.getValue()
                        }
                    }
                }
                let note = Note(num: 0, value: value)
                note.isOnlyRhythmNote = true
                timeSlice.addNote(n: note)
                totalValue += noteValue
            }
            ctr += 1
        }
        
        return outputScore
    }
        
    //From the recording of the first tick, calculate the tempo the rhythm was tapped at
    func getTempoFromRecordingStart(tapValues:[Double], questionScore: Score) -> Int {
        let scoreTimeSlices = questionScore.getAllTimeSlices()
        let firstNoteValue = scoreTimeSlices[0].notes[0].getValue()
        if self.tapValues.count == 0 {
            return 60
        }
        let firstTapValue = self.tapValues[0]
        let tempo = (firstNoteValue / firstTapValue) * 60.0
        return Int(tempo)
    }
    
    //Analyse the user's tapped rhythm and return a score representing the ticks they ticked
    func analyseRhythm(timeSignatue:TimeSignature, questionScore:Score) -> (Score, Int) {
        let tempo = getTempoFromRecordingStart(tapValues: self.tapValues, questionScore: questionScore)
        let outScore = self.makeScore(questionScore: questionScore, tempo: tempo)
        return (outScore, tempo)
    }
    
    //From the recording of ticks calculate the tempo the rhythm was tapped at
//    //Assumes quarter notes are the most frequent value in the recording
//    func getTempoFromWholeRecording(tapValues:[Double]) -> Int {
//        //round the tick values
//        var countDictionary: [Int: Int] = [:]
//        for value in tapValues {
//            let ms:Int = Int(value * 1000)
//            //let roundedNumber = ((ms + 50) / 100) * 100
//            let roundedNumber = ((ms + 100) / 200) * 200
//            //print(value, "\trounded:", roundedNumber)
//            if let count = countDictionary[roundedNumber] {
//                    countDictionary[roundedNumber] = count + 1
//            }
//            else {
//                countDictionary[roundedNumber] = 1
//            }
//        }
//        //determine the time value in ms for the quater note
//        let quarterNoteValue = countDictionary.max(by: { $0.value < $1.value })?.key
//        let tempo:Int
//        if let quarterNoteValue = quarterNoteValue {
//            tempo = Int((1000.0 / Double(quarterNoteValue))  * 60.0)
//        }
//        else {
//            tempo = 1
//        }
//        //print("\ngetTempoFromRecording counts", countDictionary, "Most frequent:", quarterNoteValue, "tempo", tempo)
//        return tempo
//    }
//    func makeScoreNew(timeSignature:TimeSignature) -> Score {
//        var outputScore = Score(timeSignature: timeSignature, lines: 1)
//        let staff = Staff(score: outputScore, type: .treble, staffNum: 0, linesInStaff: 1)
//        outputScore.setStaff(num: 0, staff: staff)
//        var ctr = 0
//        var totalValue = 0.0
//
//        for n in self.tapValues {
//
//            let noteValue = roundNoteValue(inValue: n)
//            if let noteValue = noteValue {
//                if totalValue >= Double(timeSignature.top) {
//                    print("  Barline1", totalValue, outputScore.scoreEntries.count)
//
//                    outputScore.addBarLine()
//                    totalValue = 0.0
//                    print("  Barline2", totalValue, outputScore.scoreEntries.count)
//                }
//                let timeSlice = outputScore.addTimeSlice()
//
//                let note = Note(num: 0, value: noteValue)
//                note.isOnlyRhythmNote = true
////                if ctr % 3 == 1 {
////                    note.noteTag = .inError
////                }
//                timeSlice.addNote(n: note)
//                totalValue += noteValue
//                //print("  Note value", note.value, totalValue, outputScore.scoreEntries.count)
//            }
//            ctr += 1
//        }
//        return outputScore
//    }
  
//    func analyseDifferencesNew(questionScore:Score, userScore:Score) -> Score {
//
//        class NoteMatch {
//            var note:Note
//            var playTime:Double
//            var matchQuestionNote:Note?
//
//            init(note:Note, playTime:Double) {
//                self.note = note
//                self.matchQuestionNote = nil
//                self.playTime = playTime
//            }
//        }
//
//        // build each student note's play time
//        // for each student note track the question note that it matches to
//        var userNoteMatches:[NoteMatch] = []
//        var playTime = 0.0
//        for entry in userScore.scoreEntries {
//            guard let notes = entry.getNotes() else {
//                continue
//            }
//            let note = notes[0]
//            userNoteMatches.append(NoteMatch(note: note, playTime: playTime))
//            print("user note:", note.midiNumber, note.value, "\tat", playTime)
//            playTime += note.value
//        }
//
//        // for each question note find he best student note
//        let score = Score(timeSignature: questionScore.timeSignature, lines: questionScore.staffLineCount)
//        playTime = 0.0
//        var matches:[(Note, Double, Note?)] = []
//
//        for entry in questionScore.scoreEntries {
//            if entry is TimeSlice {
//                let ts = entry as! TimeSlice
//                let questionNote = ts.notes[0]
//
//                var minDiff = Double.infinity
//                var bestFit:Note?
//
//                // find the closest user note for this question note
//                for i in 0..<userNoteMatches.count {
//                    if userNoteMatches[i].matchQuestionNote != nil {
//                        continue
//                    }
//                    let diff = abs(playTime - userNoteMatches[i].playTime)
//                    if diff < minDiff {
//                        minDiff = diff
//                        bestFit = userNoteMatches[i].note
//                    }
//                }
//                matches.append((questionNote, playTime, bestFit))
//                playTime += questionNote.value
//            }
//        }
//
//        playTime = 0
//        for match in matches {
//            print("match time:", playTime, match.1, "\tQuestion", match.0.value, "\tStudent note seq,value", match.2?.sequence,  match.2?.value)
//            playTime += match.0.value
//        }
//        return score
//    }
  
}

