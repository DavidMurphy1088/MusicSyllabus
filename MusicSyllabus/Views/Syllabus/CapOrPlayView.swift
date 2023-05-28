import SwiftUI

enum QuestionMode {
    //intervals
    case intervalVisual
    case intervalAural
    
    //rhythms
    case rhythmClap
    case rhythmPlay
    case rhythmEchoClap
    
    case none
}

struct ClapOrPlayPresentView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject private var logger = Logger.logger
    @State var tappingView:TappingView? = nil

    @State var showBaseCleff = false
    @State private var helpPopup = false
    @State var isTapping = false
    @State var rhythmHeard:Bool

    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score
    let exampleData = ExampleData.shared
    var contentSection:ContentSection
    let metronome = Metronome.getShared()
    var mode:QuestionMode
    
    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayPresentView(contentSection: contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.contentSection = contentSection
        self.mode = mode
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: (mode == .rhythmClap || mode == .rhythmEchoClap) ? 1 : 5)
        
        score.setStaff(num: 0, staff: staff)
        if mode == .rhythmPlay {
            let bstaff = Staff(score: score, type: .bass, staffNum: 1, linesInStaff: mode == .rhythmClap ? 1 : 5)
            score.setStaff(num: 1, staff: bstaff)
            score.hiddenStaffNo = 1
        }
        let exampleData = exampleData.get(contentSection: contentSection) //(contentSection.parent!.name, contentSection.name)
        score.setStaff(num: 0, staff: staff)
        self.rhythmHeard = self.mode == .rhythmEchoClap ? false : true
        var lastTS:TimeSlice? = nil
        var lastNote:Note? = nil
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = score.addTimeSlice()
                    let note = entry as! Note
                    note.staff = 0
                    note.setIsOnlyRhythm(way: mode == .rhythmClap || mode == .rhythmEchoClap ? true : false)
                    timeSlice.addNote(n: note)
                    lastTS = timeSlice
                    lastNote = note
                }
                if entry is BarLine {
                    score.addBarLine()
                }
                if entry is TimeSignature {
                    let ts = entry as! TimeSignature
                    score.timeSignature = ts
                }
                if entry is KeySignature {
                    score.setKey(key: Key(type: .major, keySig: KeySignature(type: .sharp, count: 1)))
                }
            }
            if mode == .rhythmPlay && lastNote != nil {
                let isDotted = lastNote!.isDotted
                lastTS?.tag = "I"
                if score.key.keySig.accidentalCount > 0 { //G Major
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - 5 - 12, value: lastNote!.value, staff:1, isDotted: isDotted))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - 1 - 12, value: lastNote!.value, staff:1, isDotted: isDotted))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C + 2 - 12, value: lastNote!.value, staff:1, isDotted: isDotted))
                }
                else {
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE, value: lastNote!.value, staff:1, isDotted: isDotted))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE + 4, value: lastNote!.value, staff:1, isDotted: isDotted))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE + 7, value: lastNote!.value, staff:1, isDotted: isDotted))
                }
            }
        }
        //print("\n======ClapOrPlayView init name:", contentSection.name, "score ID:", score.id, answer.state)
    }

    func getInstruction(mode:QuestionMode) -> String {
        var result = "Click start recording then "
        switch mode {
            
        case .rhythmClap:
            result += "the metronome will play the tempo. Then tap your rhythm on the drum."

        case .rhythmPlay:
            result += "play the melody and the final chord."
            
        case .rhythmEchoClap:
            result += "tap your rhythm on the drum."
            
            
        default:
            result = ""
        }
        return result + " When you are finished, stop the recording."
    }
    
    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
                VStack {
                    VStack {
//                      MetronomeView(metronome: metronome)

                        if mode == .rhythmEchoClap {
                            //play the score without showing it
                            Button(action: {
                                metronome.playScore(score: score, onDone: {self.rhythmHeard = true})
                            }) {
                                Text("Hear the rhythm")
                                    .padding()
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                            )
                            .background(UIGlobals.backgroundColor)
                            .padding()

                        }
                        else {
                            ScoreView(score: score).padding()
                        }

                        VStack {
                            if answer.state != .recording {
                                Text(self.getInstruction(mode: self.mode))
                                            .lineLimit(nil)
                                            .padding()

                                Button(action: {
                                    answer.setState(.recording)
                                    if mode == .rhythmClap || mode == .rhythmEchoClap {
                                        self.isTapping = true
                                        isTapping = true
                                        tapRecorder.startRecording(timeSignature: score.timeSignature, metronomeLeadIn: self.mode == .rhythmClap)
                                    } else {
                                        audioRecorder.startRecording()
                                    }
                                }) {
                                    Text(answer.state == .notEverAnswered ? "Start Recording" : "Redo Recording")
                                        .onAppear() {
                                            tappingView = TappingView(isRecording: $isTapping, tapRecorder: tapRecorder)
                                        }
                                }
                                .padding()
                                .disabled(!self.rhythmHeard)
                            }

                            if mode == .rhythmClap || mode == .rhythmEchoClap {
                                tappingView
                            }

                            if answer.state == .recording {
                                Button(action: {
                                    answer.setState(.recorded)
                                    if mode == .rhythmClap || mode == .rhythmEchoClap {
                                        self.isTapping = false
                                        self.tapRecorder.stopRecording()
                                        isTapping = false
                                    }
                                    else {
                                        audioRecorder.stopRecording()
                                    }
                                }) {
                                    Text("Stop Recording")
                                }.padding()
                            }
                            
                            if answer.state == .recorded {
                                Button(action: {
                                    answer.setState(.submittedAnswer)
                                    score.setHiddenStaff(num: nil)
                                    self.showBaseCleff = true
                                    
                                }) {
                                    Text("Check Your Answer")
                                }
                                .padding()
                            }
                            
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                        )
                        .background(UIGlobals.backgroundColor)
                        .padding()
                        
                        Text(audioRecorder.status).padding()
                        if logger.status.count > 0 {
                            Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
                        }
                    }
                }
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFontSize : UIFont.systemFontSize * 1.6))
                .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
            }
        )
    }
}

struct ClapOrPlayAnswerView: View, QuestionPartProtocol {
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject var answer:Answer
    @ObservedObject private var logger = Logger.logger
    @ObservedObject var audioRecorder = AudioRecorder.shared
    
    @State var playingCorrect = false
    @State var playingStudent = false
    @State var speechEnabled = false
    @State var tappingScore:Score?
    
    private var score:Score
    private let metronome = Metronome.getShared()
    private var mode:QuestionMode

    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayAnswerView(contentSection:contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.mode = mode
        if mode == .rhythmClap {
            self.tappingScore = Score(timeSignature: score.timeSignature, lines: 1)
        }
        metronome.speechEnabled = self.speechEnabled

    }
    var speechEnabledView : some View {
        //voice on/off
        VStack {
            Button(action: {
                self.speechEnabled.toggle()
                metronome.speechEnabled = self.speechEnabled
            }) {
                HStack {
                    if !self.speechEnabled {
                        Image(systemName: "person.fill")
                            .foregroundColor(.black)
                            .scaleEffect(3.0)
                            .padding()
                    }
                    else {
                        Image(systemName: "person.fill")
                        //.frame(width: geometry.size.width / 20.0)
                            .foregroundColor(.green)
                            .scaleEffect(3.0)
                            .padding()
                    }
                }
            }
        }
        .padding()
    }
    
    var stopPlayView : some View {
        VStack {
            Button(action: {
                metronome.playScore(score: score, onDone: {playingCorrect = false})
                playingCorrect = true
                
            }) {
                if playingCorrect {
                    Button(action: {
                        playingCorrect = false
                        metronome.stopPlayingScore()
                    }) {
                        Text("Stop Playing")
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }
                else {
                    Text("Hear the Correct \((mode == .rhythmClap || mode == .rhythmEchoClap)  ? "Rhythm" : "Playing")")
                        .buttonStyle(DefaultButtonStyle())
                }
            }
            .padding()
            
            //Hear user rhythm
            Button(action: {
                if mode == .rhythmClap || mode == .rhythmEchoClap {
                    if tappingScore != nil {
                        metronome.playScore(score: tappingScore!, onDone: {
                            playingStudent = false
                        })
                    }
                    playingStudent = true
                }
                else {
                    audioRecorder.playRecording()
                }
            }) {
                if playingStudent {
                    Button(action: {
                        playingStudent = false
                        metronome.stopPlayingScore()
                    }) {
                        Text("Stop Playing")
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }
                else {
                    Text("Hear Your \((mode == .rhythmClap || mode == .rhythmEchoClap) ? "Rhythm" : "Playing")")
                        .font(.system(.body))
                }
            }
            .padding()
        }
        .padding()
    }
    
    func getFeedback(diffNote:Int?) -> StudentFeedback {
        var s = StudentFeedback()
        if let diffNote = diffNote {
            s.feedback = "Mistake at note \(diffNote+1)"
            s.correct = false
        }
        else {
            s.correct = true
            s.feedback = "Good job!"
        }
        return s
    }
    
    func analyseRhythm() {
            tappingScore = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, inputScore: score)
            if let tappingScore = tappingScore {
                let difference = score.GetFirstDifferentTimeSlice(compareScore: tappingScore)
                if let diff = difference {
                    if tappingScore.scoreEntries.count > 0 {
                        let entry = tappingScore.scoreEntries[diff.0]
                        if let ts = entry as! TimeSlice? {
                            if ts.notes.count > 0 {
                                ts.notes[0].noteTag = .inError
                            }
                        }
                        tappingScore.setStudentFeedback(studentFeedack: self.getFeedback(diffNote: diff.1))
                    }
                }
                else {
                    tappingScore.setStudentFeedback(studentFeedack: self.getFeedback(diffNote: nil))
                }
            }
            tappingScore?.label = "Your Rhythm"
    }

    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
                VStack {
                    MetronomeView()
                    VStack {
                        ScoreView(score: score).padding()
                        if tappingScore != nil {
                            ScoreView(score: tappingScore!).padding()
                        }
                    }

                    HStack {
                        HStack {
                            stopPlayView
                                .padding()
                                .onAppear {
                                    if mode == .rhythmClap || mode == .rhythmEchoClap {
                                        analyseRhythm()
                                    }
                                }
                            speechEnabledView
                                .padding()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                        )
                        .background(UIGlobals.backgroundColor)
                        .padding()
                    }
                    
                    Text(audioRecorder.status).padding()
                    if logger.status.count > 0 {
                        Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
                    }
                }
            }
        )
    }
}

struct ClapOrPlayView: View {
    let id = UUID()
    var contentSection:ContentSection
    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score = Score(timeSignature: TimeSignature(top: 4, bottom: 4), lines: 5)
    @ObservedObject var answer: Answer = Answer()
    var presentQuestionView:ClapOrPlayPresentView?
    var answerQuestionView:ClapOrPlayAnswerView?
    
    init(mode:QuestionMode, contentSection:ContentSection) {
        self.contentSection = contentSection
        presentQuestionView = ClapOrPlayPresentView(contentSection: contentSection, score: self.score, answer: answer, mode: mode)
        answerQuestionView = ClapOrPlayAnswerView(contentSection: contentSection, score: score, answer: answer, mode: mode)
        //print("\n======QuestionAndAnswerView init name:", contentSection.name, "self ID", id, "score ID:", score.id)
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
