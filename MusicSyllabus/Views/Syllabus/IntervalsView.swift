import SwiftUI
import CoreData

struct IntervalsAnswerView:View {
    @Binding var answered:IntervalsView.AnswerState
    @State var metronome = Metronome.shared
    var score:Score
    var answerCorrect:Bool
    var correctInterval:Int
    
    private let imageSize = Double(32)
    private var intervals:[IntervalsView.IntervalName]
    private var noteIsSpace:Bool
    private var correctIntervalName:IntervalsView.IntervalName
    
    init(answered:Binding<IntervalsView.AnswerState>, metronome:Metronome, score:Score, answerCorrect:Bool, correctInterval: Int, intervals:[IntervalsView.IntervalName], intervalNotes:[Note]) {
        correctIntervalName = intervals.first(where: { $0.interval == correctInterval})!
        _answered = answered
        self.score = score
        self.answerCorrect = answerCorrect
        self.correctInterval = correctInterval
        self.intervals = intervals
        self.noteIsSpace = [Note.MIDDLE_C + 5, Note.MIDDLE_C + 9, Note.MIDDLE_C + 12,
                            Note.MIDDLE_C + 16].contains(intervalNotes[0].midiNumber)
    }
    
    var body: some View {
        VStack {
            HStack {
                if answerCorrect {
                    Image(systemName: "checkmark.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.green)
                    Text("Good job, correct")
                }
                else {
                    Image(systemName: "staroflife.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.red)
                    Text("Sorry, not correct")
                }
            }
            .padding()
            Text("The interval is a \(correctIntervalName.name)").padding()
            Text(correctIntervalName.explanation[self.noteIsSpace ? 1 : 0]).italic().padding()
            Button(action: {
                metronome.playScore(score: score)
            }) {
                Text("Hear Interval")
            }
            Spacer()
            Button(action: {
                answered = .notAnswered
            }) {
                Text("Next Questioon")
            }
            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
        )
        .padding()
    }
}

struct IntervalsView:View {
    var contentSection:ContentSection
    @State var metronome = Metronome.shared
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 5)
    @State private var answerState:AnswerState = .notAnswered
    @State private var selectedInterval:Int? = nil
    let exampleData = ExampleData.shared
    private var selectedAnswer: String? = nil
    
    class IntervalName : Hashable {
        var interval: Int
        var name:String
        var explanation:[String]
        init(interval:Int, name:String, explanation:[String]) {
            self.interval = interval
            self.name = name
            self.explanation = explanation
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(interval)
        }
        static func == (lhs: IntervalsView.IntervalName, rhs: IntervalsView.IntervalName) -> Bool {
            return lhs.interval == rhs.interval
        }
    }
    let options = [IntervalName(interval:2, name: "Second",
                                explanation: ["A line to a space is a step which is a second interval",
                                              "A space to line is a step which is a second interval"]),
                   IntervalName(interval:3, name: "Third",
                                explanation: ["A line to a line is a skip which is a third interval",
                                              "A space to space is a skip which is a third interval"])]
    var intervalNotes:[Note] = []
    
    enum AnswerState {
        case notAnswered
        case selectedAnAnswer
        case submittedAnswer
    }
    
    init(contentSection:ContentSection) {
        self.contentSection = contentSection
        let exampleData = exampleData.get(contentSection.parent!.name, contentSection.name)
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        score.setStaff(num: 0, staff: staff)
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = score.addTimeSlice()
                    let note = entry as! Note
                    timeSlice.addNote(n: note)
                    intervalNotes.append(note)
                }
            }
        }
        score.addBarLine(atScoreEnd: true)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    ScoreView(score: score).padding()
                }
                
                VStack {
                    Text("Please choose the correct interval type").padding()
                    Picker("Select an option", selection: $selectedInterval) {
                        ForEach(options, id: \.self) { option in
                            Text(option.name).tag(option.interval as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                    //.pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedInterval) { newValue in
                        //print("Selection changed to index \(newValue)")
                        answerState = .selectedAnAnswer
                    }
                    .padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
                )
                .padding()
            }

            if answerState == .selectedAnAnswer {
                Button(action: {
                    answerState = .submittedAnswer
                }) {
                    Text("Check Your Answer")
                }
                .padding()
            }
            
            if answerState == .submittedAnswer {
                let interval = abs((intervalNotes[1].midiNumber - intervalNotes[0].midiNumber))
                let correct = selectedInterval == interval
                IntervalsAnswerView(answered: $answerState, metronome: metronome, score: score, answerCorrect: correct, correctInterval: interval, intervals: self.options, intervalNotes: intervalNotes)
            }
        }
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
    }
}

