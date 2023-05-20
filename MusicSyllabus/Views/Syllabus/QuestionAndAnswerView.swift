import SwiftUI


//All question presentations and answers follow this protocol
protocol AnswerStateProtocol {
    var body: AnyView { get }
    init(contentSection:ContentSection, score:Score, answerState:Binding<Answer>)
    static func createInstance(contentSection:ContentSection, score:Score, answer:Binding<Answer>) -> AnswerStateProtocol
}

// the answer a student gives to a question
class Answer : ObservableObject {
    var notes:[Note] = []
    var correct: Bool = false
    @Published var state:AnswerState = .notEverAnswered
    enum AnswerState {
        case notEverAnswered
        case recording
        case answered
        case submittedAnswer
    }
    func setState(state:AnswerState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}

class PickerState : ObservableObject {
    var selectedInterval:Int? = nil
}

struct IntervalPresentView: View, AnswerStateProtocol {
    @Binding var answer:Answer
    var score:Score
    let exampleData = ExampleData.shared
    var intervalNotes:[Note] = []
    @State private var logger = Logger.logger
    @ObservedObject var pState = PickerState()
    
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
        static func == (lhs: IntervalPresentView.IntervalName, rhs: IntervalPresentView.IntervalName) -> Bool {
            return lhs.interval == rhs.interval
        }
    }

    let options = [IntervalName(interval:2, name: "Second",
                                explanation: ["A line to a space is a step which is a second interval",
                                              "A space to a line is a step which is a second interval"]),
                   IntervalName(interval:3, name: "Third",
                                explanation: ["A line to a line is a skip which is a third interval",
                                              "A space to a space is a skip which is a third interval"])]

    init(contentSection:ContentSection, score:Score, answerState:Binding<Answer>) {
        _answer = answerState
        self.score = score
        //self.contentSection = contentSection
        let exampleData = exampleData.get(contentSection: contentSection) //contentSection.parent!.name, contentSection.name, exampleKey: contentSection.gr)
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
    
    var body: AnyView {
        AnyView(
        VStack {
            HStack {
                ScoreView(score: score).padding()
            }
            VStack {
                VStack {
                    Text("Please choose the correct interval type").padding()
                    Picker("Select an option", selection: $pState.selectedInterval) {
                        ForEach(options, id: \.self) { option in
                            Text(option.name).tag(option.interval as Int?)
                        }
                    }
                    .pickerStyle(.segmented)
                    //.pickerStyle(MenuPickerStyle())
                    .onChange(of: pState.selectedInterval) { newValue in
                        print("Selection changed to index \(newValue)")
                        answer.setState(state: .answered)
                    }
                    .padding()
                    
                }
                .overlay(
                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                )
                .background(UIGlobals.backgroundColor)
                .padding()
            }

            if answer.state == .answered {
                VStack {
                    Button(action: {
                        answer.setState(state: .submittedAnswer)
                        print("answer set to submitted")
                    }) {
                        Text("Check Your Answer")
                    }
                    .padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                )
                .background(UIGlobals.backgroundColor)
                .padding()
            }

            if answer.state == .submittedAnswer {
                let interval = abs((intervalNotes[1].midiNumber - intervalNotes[0].midiNumber))
                //answer.correct = pState.selectedInterval == interval
            }
            if logger.status != nil {
                Text(logger.status!).foregroundColor(logger.isError ? .red : .gray)
            }

        }
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
        )
    }
    
    static func createInstance(contentSection:ContentSection, score:Score, answer:Binding<Answer>) -> AnswerStateProtocol {
        return IntervalPresentView(contentSection: contentSection, score:score, answerState: answer)
    }
}

struct IntervalAnswerView: View, AnswerStateProtocol {
    @Binding var answerState:Answer
    private var score:Score

    let answerCorrect = true
    private let imageSize = Double(32)
    //private var correctIntervalName:IntervalsView.IntervalName
    private let metronome = Metronome.shared
    private var noteIsSpace:Bool
    let correctInterval = 0
    
    static func createInstance(contentSection:ContentSection, score:Score, answer:Binding<Answer>) -> AnswerStateProtocol {
        return IntervalAnswerView(contentSection:contentSection, score:score, answerState: answer)
    }
    
    init(contentSection:ContentSection, score:Score, answerState:Binding<Answer>) {
        _answerState = answerState
        self.score = score
        self.noteIsSpace = true //[Note.MIDDLE_C + 5, Note.MIDDLE_C + 9, Note.MIDDLE_C + 12, Note.MIDDLE_C + 16].contains(intervalNotes[0].midiNumber)
       // self.correctIntervalName = "..." //intervals.first(where: { $0.interval == correctInterval})!
    }
    
    var body: AnyView {
        AnyView(
            VStack {
                HStack {
                    ScoreView(score: score).padding()
                }

                VStack {
                    HStack {
                        if answerCorrect {
                            Image(systemName: "checkmark.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.green)
                            Text("Correct - Good job")
                        }
                        else {
                            Image(systemName: "staroflife.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.red)
                            Text("Sorry, not correct")
                        }
                    }
                    .padding()
                    //Text("The interval is a \(correctIntervalName.name)").padding()
                    //Text(correctIntervalName.explanation[self.noteIsSpace ? 1 : 0]+".").italic().fixedSize(horizontal: false, vertical: true).padding()
                    Button(action: {
                        metronome.playScore(score: score)
                    }) {
                        Text("Hear Interval")
                    }
                    .padding()
                    //            Button(action: {
                    //                answered = .notAnswered
                    //            }) {
                    //                Text("Next Questioon")
                    //            }
                    //            .padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                )
                .background(UIGlobals.backgroundColor)
                .padding()
            }
        )
    }
}

struct QuestionAndAnswerView: View {
    @State var answer: Answer = Answer()
    @State var metronome = Metronome.shared
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 5)
    @State var presentStateView:AnswerStateProtocol?
    @State var answerStateView:AnswerStateProtocol?
    
    var presentStateType:AnswerStateProtocol.Type
    var answerStateType:AnswerStateProtocol.Type
    var contentSection:ContentSection
    
    init(presentType:AnswerStateProtocol.Type, answerType:AnswerStateProtocol.Type, contentSection:ContentSection) {
        presentStateType = presentType
        answerStateType = answerType
        self.contentSection = contentSection
    }
    
    func initViewInstances() {
        presentStateView = presentStateType.createInstance(contentSection: contentSection, score:score, answer: $answer)
        answerStateView = answerStateType.createInstance(contentSection: contentSection, score:score, answer: $answer)
    }

    var body: some View {
        VStack {
            if answer.state != .submittedAnswer {
                if presentStateView != nil {
                    presentStateView!.body
                }
            }
            else {
                if answerStateView != nil {
                    answerStateView!.body
                }
            }
        }
        .onAppear {
            initViewInstances()
        }
    }
}

