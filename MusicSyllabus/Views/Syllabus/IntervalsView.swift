import SwiftUI

struct IntervalPresentView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    var score:Score
    let exampleData = ExampleData.shared
    var intervalNotes:[Note] = []
    @ObservedObject private var logger = Logger.logger
    @State private var selectedIntervalIndex = 0
    var mode:QuestionMode
    let metronome = Metronome.shared

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
    
    let intervals = [IntervalName(interval:2, name: "Second",
                                explanation: ["A line to a space is a step which is a second interval",
                                              "A space to a line is a step which is a second interval"]),
                   IntervalName(interval:3, name: "Third",
                                explanation: ["A line to a line is a skip which is a third interval",
                                              "A space to a space is a skip which is a third interval"])]
    
    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return IntervalPresentView(contentSection: contentSection, score:score, answer: answer, mode:mode )
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.mode = mode
        let exampleData = exampleData.get(contentSection: contentSection) //contentSection.parent!.name, contentSection.name, exampleKey: contentSection.gr)
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        
        self.score.setStaff(num: 0, staff: staff)
        //print("  IntervalPresentView INIT score:", score.id)
        var chord:Chord = Chord()
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    //print("    IntervalPresentView INIT new time slice in ", score.id)
                    let timeSlice = self.score.addTimeSlice()
                    let note = entry as! Note
                    timeSlice.addNote(n: note)
                    intervalNotes.append(note)
                    if mode == .intervalAural {
                        chord.notes.append(Note(num: note.midiNumber))
                    }
                }
            }
        }
        if chord.notes.count > 0 {
            score.addTimeSlice().addChord(c: chord)
        }
        score.addBarLine(atScoreEnd: true)
    }

    var body: AnyView {
    //var body: some View {
        AnyView(
            VStack {
                HStack {
                    if mode == .intervalVisual {
                        ScoreView(score: score).padding()
                    }
                    else {
                        Button(action: {
                            metronome.playScore(score: score)
                        }) {
                            Text("Hear Interval")
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                        )
                        .background(UIGlobals.backgroundColor)
                        .padding()
                    }
                }
                VStack {
                    VStack {
                        //Text("Please choose the correct interval type").padding()
                        Picker("Select an option", selection: $selectedIntervalIndex) {
                            ForEach(0..<intervals.count) { index in
                                Text(intervals[index].name)
                            }
                        }
                        
                        .pickerStyle(.segmented)
                        //.pickerStyle(.inline)
                        //.pickerStyle(MenuPickerStyle())
                        
                        //.onChange(of: answer.selectedInterval) { newValue in
                        .onChange(of: selectedIntervalIndex) { index in
                            print("=========================== Selection changed to index \(index)")
                            answer.setState(.answered)
                            answer.selectedInterval = intervals[index].interval
                        }
                        .padding()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                    )
                    .background(UIGlobals.backgroundColor)
                    .padding()
                }
                
                VStack {
                    if answer.state == .answered {
                        Button(action: {
                            answer.setState(.submittedAnswer)
                            let interval = abs((intervalNotes[1].midiNumber - intervalNotes[0].midiNumber))
                            if answer.selectedInterval == interval {
                                answer.correct = true
                                answer.correctInterval = interval
                            }
                            else {
                                answer.correct = false
                                answer.correctInterval = interval
                            }
                            let name = intervals.first(where: { $0.interval == answer.correctInterval})
                            if name != nil {
                                answer.correctIntervalName = name!.name
                                let noteIsSpace = [Note.MIDDLE_C + 5, Note.MIDDLE_C + 9, Note.MIDDLE_C + 12, Note.MIDDLE_C + 16].contains(intervalNotes[0].midiNumber)
                                answer.explanation = name!.explanation[noteIsSpace ? 1 : 0]
                            }
                        }) {
                            Text("Check Your Answer")
                        }
                        .padding()
                    }
                    else {
                        Text("Please choose the correct interval type").padding()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                )
                .background(UIGlobals.backgroundColor)
                .padding()

                if logger.status.count > 0 {
                    Text(logger.status).foregroundColor(logger.isError ? .red : .gray)
                }

        }
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
        .onAppear() {
            Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { _ in
                metronome.playScore(score: score)
            }
        }
        )
    }
}


struct IntervalAnswerView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    private var score:Score
    private let imageSize = Double(32)
    private let metronome = Metronome.shared
    private var noteIsSpace:Bool

    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return IntervalAnswerView(contentSection:contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.noteIsSpace = true //[Note.MIDDLE_C + 5, Note.MIDDLE_C + 9, Note.MIDDLE_C + 12, Note.MIDDLE_C + 16].contains(intervalNotes[0].midiNumber)
    }
    
    var body: AnyView {
        AnyView(
            VStack {
                HStack {
                    ScoreView(score: score).padding()
                }

                VStack {
                    HStack {
                        if answer.correct {
                            Image(systemName: "checkmark.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.green)
                            Text("Correct - Good job")
                        }
                        else {
                            Image(systemName: "staroflife.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.red)
                            Text("Sorry, not correct")
                        }
                    }
                    .padding()
                    
                    Text("The interval is a \(answer.correctIntervalName)").padding()
                    Text(answer.explanation).italic().fixedSize(horizontal: false, vertical: true).padding()
                    
                    Button(action: {
                        metronome.playScore(score: score)
                    }) {
                        Text("Hear Interval")
                    }
                    .padding()
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

struct IntervalView: View {
    let id = UUID()
    var contentSection:ContentSection
    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score = Score(timeSignature: TimeSignature(top: 4, bottom: 4), lines: 5)
    @ObservedObject var answer: Answer = Answer()
    var presentQuestionView:IntervalPresentView?
    var answerQuestionView:IntervalAnswerView?
    
    init(mode:QuestionMode, contentSection:ContentSection) {
        self.contentSection = contentSection
        presentQuestionView = IntervalPresentView(contentSection: contentSection, score: self.score, answer: answer, mode:mode)
        answerQuestionView = IntervalAnswerView(contentSection: contentSection, score: score, answer: answer, mode:mode)
        //print("\n======QuestionAndAnswerView init name:", contentSection.name, contentSection.sectionType, "self ID", id, "score ID:", score.id)
    }

    var body: some View {
        VStack {
            if answer.state != .submittedAnswer {
                presentQuestionView
            }
            else {
                answerQuestionView
            }
        }
    }
}

struct QuestionAndAnswerViewGeneric_Bad: View {
    //this struct causes the picker in the answer presenter to generate faults about the picker writing to the struct but outside of the struct
    @ObservedObject var answer: Answer = Answer()
    @State var metronome = Metronome.shared
    @State var score:Score = Score(timeSignature: TimeSignature(top: 4, bottom: 5), lines: 5)
    @State var presentStateView:QuestionPartProtocol?
    @State var answerStateView:QuestionPartProtocol?
    
    var presentStateType:QuestionPartProtocol.Type
    var answerStateType:QuestionPartProtocol.Type
    var contentSection:ContentSection
    
    init(mode:QuestionMode, presentType:QuestionPartProtocol.Type, answerType:QuestionPartProtocol.Type, contentSection:ContentSection) {
        presentStateType = presentType
        answerStateType = answerType
        self.contentSection = contentSection
        //print("======QuestionAndAnswerView init", contentSection.parent, contentSection.sectionType)
//    }
//
//    func initViewInstances() {
        presentStateView = presentStateType.createInstance(contentSection: contentSection, score:score, answer: answer, mode: mode)
        answerStateView = answerStateType.createInstance(contentSection: contentSection, score:score, answer: answer, mode: mode)
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

    }
}

