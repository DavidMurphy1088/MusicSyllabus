import SwiftUI

enum QuestionMode {
    //intervals
    case intervalVisual
    case intervalAural
    
    //rhythms
    case rhythmVisualClap
    case melodyPlay
    case rhythmEchoClap
    
    case none
}

struct PlayRecordingView: View {
    var mode:QuestionMode
    var buttonLabel:String
    @State var score:Score?
    @State var metronome:Metronome
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @State var playingScore:Bool = false
    var onDone: (()->Void)?

    var body: some View {
        VStack {
            Button(action: {
                if let score = score {
                    metronome.playScore(score: score, onDone: {
                        playingScore = false
                        if let onDone = onDone {
                            onDone()
                        }
                    })
                    playingScore = true
                }
                else {
                    audioRecorder.playRecording()
                }
            }) {
                if playingScore {
                    Button(action: {
                        playingScore = false
                        metronome.stopPlayingScore()
                    }) {
                        Text("Stop Playing")
                            //.font(.body)
                            .foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.cornerRadius).padding()
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                }
                else {
                    Text(self.buttonLabel)
                        //.font(.body)
                        .foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.cornerRadius).padding()
                }
            }
            .padding()
        }
    }
}

struct ClapOrPlayPresentView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject private var logger = Logger.logger
    @ObservedObject private var metronome = Metronome.getMetronomeWithSettings(initialTempo: 60, allowChangeTempo: true)

    @State var tappingView:TappingView? = nil

    //@State var showBaseCleff = false
    @State private var helpPopup = false
    @State var isTapping = false
    @State var rhythmHeard:Bool

    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score
    let exampleData = ExampleData.shared
    var contentSection:ContentSection
    var mode:QuestionMode
    var onRefresh: (() -> Void)? = nil
    
    static func onRefresh() {
    }
    
    //static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol
    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayPresentView(contentSection: contentSection, score:score, answer: answer, mode: mode, refresh: onRefresh)
    }
    
    //in(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode, refresh:(() -> Void)?)
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode, refresh:(() -> Void)? = nil) {
        self.answer = answer
        self.score = score
        self.contentSection = contentSection
        self.mode = mode
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: (mode == .rhythmVisualClap || mode == .rhythmEchoClap) ? 1 : 5)
        
        score.setStaff(num: 0, staff: staff)
        if mode == .melodyPlay {
            let bstaff = Staff(score: score, type: .bass, staffNum: 1, linesInStaff: mode == .rhythmVisualClap ? 1 : 5)
            score.setStaff(num: 1, staff: bstaff)
            score.hiddenStaffNo = 1
        }
        let exampleData = exampleData.get(contentSection: contentSection) //(contentSection.parent!.name, contentSection.name)
        score.setStaff(num: 0, staff: staff)
        self.rhythmHeard = self.mode == .rhythmEchoClap ? false : true
//        var lastTS:TimeSlice? = nil
//        var lastNote:Note? = nil
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = score.addTimeSlice()
                    let note = entry as! Note
                    note.staffNum = 0
                    note.setIsOnlyRhythm(way: mode == .rhythmVisualClap || mode == .rhythmEchoClap ? true : false)
                    timeSlice.addNote(n: note)
//                    lastTS = timeSlice
//                    lastNote = note
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
        }
        if mode == .rhythmEchoClap {
            metronome.setTempo(tempo: 90)
            metronome.setAllowTempoChange(allow: false)
        }
    }

    func getInstruction(mode:QuestionMode) -> String {
        var result = "Press start recording then "
        switch mode {
            
        case .rhythmVisualClap:
            //result += "you will be counted in for one full bar. Then tap your rhythm on the drum."
            result += "tap your rhythm on the drum."

        case .melodyPlay:
            result += "play the melody and the final chord."
            
        case .rhythmEchoClap:
            result += "tap your rhythm on the drum."
            
        default:
            result = ""
        }
        return result + " When you are finished stop the recording."
    }
    
    func getStudentScore() -> Score {
        let rhythmAnalysis = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, questionScore: score)
        return rhythmAnalysis.0
    }
    
    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
                VStack {
                    VStack {
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            //if mode != .rhythmVisualClap {
                                ToolsView(score: score)
                                //MetronomeView()
                            //}
                        }

                        if mode == .rhythmVisualClap || mode == .melodyPlay {
                            ScoreView(score: score).padding()
                        }
                        
                        if mode == .melodyPlay || mode == .rhythmEchoClap {
                            PlayRecordingView(mode: mode, buttonLabel: "Hear The Given \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                              score: score, metronome: metronome, onDone: {rhythmHeard = true})
                        }
                        
                        VStack {
                            Text(self.getInstruction(mode: self.mode))
                                        .lineLimit(nil)
                                        .padding()
                            
                            if answer.state != .recording {
                                if rhythmHeard {
                                    Button(action: {
                                        answer.setState(.recording)
                                        if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                                            self.isTapping = true
                                            metronome.stopTicking()
                                            tapRecorder.startRecording(metronomeLeadIn: false)
                                        } else {
                                            audioRecorder.startRecording(outputFileName: contentSection.name)
                                        }
                                    }) {
                                        Text(answer.state == .notEverAnswered ? "Start Recording" : "Redo Recording")
                                            .foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.buttonCornerRadius).padding()
                                            .onAppear() {
                                                tappingView = TappingView(isRecording: $isTapping, tapRecorder: tapRecorder)
                                            }
                                    }
                                }
                            }
                            
                            if answer.state == .recording {
                                Button(action: {
                                    answer.setState(.recorded)
                                    if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                                        self.isTapping = false
                                        self.tapRecorder.stopRecording()
                                        isTapping = false
                                    }
                                    else {
                                        audioRecorder.stopRecording()
                                    }
                                }) {
                                    Text("Stop Recording")
                                        .foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.buttonCornerRadius)
                                }.padding()
                            }
  
                            if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                                tappingView.padding()
                            }

                            if answer.state == .recorded {
                                PlayRecordingView(mode: mode, buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                                  score: mode == .melodyPlay ? nil : getStudentScore(), metronome: self.metronome)
                            }
                            
                            if answer.state == .recorded {
                                Button(action: {
                                    answer.setState(.submittedAnswer)
                                    score.setHiddenStaff(num: nil)
                                    //self.showBaseCleff = true
                                    
                                }) {
                                    //Stop the UI jumping around when answer.state changes state
                                    Text(answer.state == .recorded ? "Check Your Answer" : "")
                                        .foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.buttonCornerRadius)
                                }
                                .padding()
                            }
                            Text("  ").padding()
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
                    .onAppear() {
                        score.setHiddenStaff(num: 1)
                    }
                }
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFontSize : UIFont.systemFontSize * 1.6))
                //.navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
            }
        )
    }
}

struct ClapOrPlayAnswerView: View, QuestionPartProtocol {
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject var answer:Answer
    var onRefresh:(()->Void)?
    
    @ObservedObject private var logger = Logger.logger
    @ObservedObject var audioRecorder = AudioRecorder.shared
    
    @State var playingCorrect = false
    @State var playingStudent = false
    @State var speechEnabled = false
    @State var tappingScore:Score?
    @ObservedObject var metronome:Metronome
    @State var answerWasCorrect:Bool = false
    @ObservedObject var score:Score
    private var mode:QuestionMode

    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayAnswerView(contentSection:contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode, refresh:(() -> Void)? = nil) {
        self.answer = answer
        self.score = score
        self.mode = mode
        self.metronome = Metronome.getMetronomeWithCurrentSettings()
        metronome.speechEnabled = self.speechEnabled
        self.onRefresh = refresh
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
        
    func analyseStudentRhythm() {
        let rhythmAnalysis = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, questionScore: score)
        self.tappingScore = rhythmAnalysis.0
        let tappingTempo = rhythmAnalysis.1
        if let tappingScore = tappingScore {
            let errorsExist = score.markupStudentScore(scoreToCompare: tappingScore)
            self.answerWasCorrect = !errorsExist
            if errorsExist {
                self.metronome.setTempo(tempo: 60)
                self.metronome.setAllowTempoChange(allow: false)
            }
            else {
                self.metronome.setTempo(tempo: tappingTempo)
                self.metronome.setAllowTempoChange(allow: true)
            }
            tappingScore.label = "Your Rhythm"
        }
    }

    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
                VStack {
                    if UIDevice.current.userInterfaceIdiom != .phone {
                        ToolsView(score: score)
                    }
                    VStack {
                        ScoreView(score: score).padding()
                        if let tappingScore = self.tappingScore {
                            ScoreView(score: tappingScore).padding()
                        }
                    }

                    HStack {
                        VStack {
                            
                            PlayRecordingView(mode: mode, buttonLabel: "Hear The Given \(mode == .melodyPlay ? "Melody" : "Rhythm")", score: score, metronome: metronome)

                            if mode == .melodyPlay {
                                PlayRecordingView(mode: mode, buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")", score: nil, metronome: metronome)
                            }
                            else {
                                if let tappingScore = self.tappingScore {
                                    PlayRecordingView(mode: mode, buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")", score: tappingScore, metronome: metronome)
                                }
                            }
                            
                            //speechEnabledView.padding()
                            
                            Button(action: {
                                if let refresh = self.onRefresh {
                                    refresh()
                                }
                            }) {
                                Text("Try Again").foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.cornerRadius).padding()
                            }
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
                .onAppear() {
                    if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                        analyseStudentRhythm()
                    }
                    if mode == .melodyPlay {
                        metronome.allowChangeTempo = false
                        if let timeSlice = score.getLastTimeSlice() {
                            timeSlice.addTonicChord()
                            timeSlice.setTags(high: "G", low: "I")
                        }
                    }
                    if mode == .rhythmEchoClap {
                        metronome.setTempo(tempo: 90)
                    }
                }
                .onDisappear() {
                    score.clearTages() //clear tags from any previous attempt
                }
            }
        )
    }
}

struct ClapOrPlayView: View {
    let id = UUID()
    var contentSection:ContentSection
    @State var refresh:Bool = false
    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score = Score(timeSignature: TimeSignature(top: 4, bottom: 4), lines: 5)
    @ObservedObject var answer: Answer = Answer()
    var presentQuestionView:ClapOrPlayPresentView?
    var answerQuestionView:ClapOrPlayAnswerView?
    
    func onRefresh() {
        self.answer.setState(.notEverAnswered)
        DispatchQueue.main.async {
            self.refresh.toggle()
        }
    }

    init(mode:QuestionMode, contentSection:ContentSection) {
        self.contentSection = contentSection
        presentQuestionView = ClapOrPlayPresentView(contentSection: contentSection, score: score, answer: answer, mode: mode)
        answerQuestionView = ClapOrPlayAnswerView(contentSection: contentSection, score: score, answer: answer, mode: mode, refresh: onRefresh)
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
