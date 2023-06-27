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

struct PracticeToolView: View {
    var text:String
    var body: some View {
        HStack {
            Text("Practice Tool:")//.padding()
            Text(text)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColorDarker)
    }
}

struct PlayRecordingView: View {
    var buttonLabel:String
    @State var score:Score?
    @State var metronome:Metronome
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @State private var playingScore:Bool = false
    var onStart: (()->Void)?
    var onDone: (()->Void)?

    var body: some View {
        VStack {
            Button(action: {
                if let onStart = onStart {
                    onStart()
                }
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
    @ObservedObject private var metronome:Metronome = Metronome.getMetronomeWithCurrentSettings(ctx: "ClapOrPlayPresentView init @ObservedObject")

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
    let questionTempo = 90
    
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
        self.rhythmHeard = self.mode == .rhythmVisualClap ? true : false
        
        if let entries = exampleData {
            var ctr = 0
            for entry in entries {
                if entry is Note {
                    let timeSlice = score.addTimeSlice()
                    let note = entry as! Note
                    note.staffNum = 0
                    note.setIsOnlyRhythm(way: mode == .rhythmVisualClap || mode == .rhythmEchoClap ? true : false)
                    timeSlice.addNote(n: note)
//                    ctr += 1
//                    if ctr > 3 {
//                        break
//                    }
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
        if mode == .melodyPlay {
            if let timeSlice = score.getLastTimeSlice() {
                timeSlice.addTonicChord()
                timeSlice.setTags(high: score.key.keySig.accidentalCount > 0 ? "G" : "C", low: "I")
            }
        }
    }

    func getInstruction(mode:QuestionMode) -> String {
        var result = "Press Start Recording then "
        switch mode {
            
        case .rhythmVisualClap, .rhythmEchoClap:
            //result += "you will be counted in for one full bar. Then tap your rhythm on the drum."
            result += "tap the given rhythm on the drum below."
            result += "\n\nFor a clear result, you should tap and then immediately release your finger (like a staccato motion), rather than holding it down on the device."
            result += "\n\nWhen you have finished, stop the recording."
            result += " If you tap the rhythm incorrectly, you will be able to hear your rhythm and the given rhythm at crotchet = 90 on the next page."

        case .melodyPlay:
            result += "play the melody and the final chord."
            result += "\n\nWhen you have finished, stop the recording."

//        case :
//            result += "tap your rhythm on the drum. Remember to tap rather than hold your finger firmly down."
            
        default:
            result = ""
        }
        return result
    }
    
    func getStudentScoreWithTempo() -> Score {
        let rhythmAnalysis = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, questionScore: score)
        return rhythmAnalysis
    }
    
    var body: AnyView {
        AnyView(
            //GeometryReader { geo in
                VStack {
                    VStack {
                        if UIDevice.current.userInterfaceIdiom != .phone {
                            if mode == .melodyPlay || mode == .rhythmEchoClap {
                                ToolsView(score: score)
                            }
                        }

                        if mode == .rhythmVisualClap || mode == .melodyPlay {
                            ScoreView(score: score, screenWidth: UIScreen.main.bounds.width).padding()
                        }
                        
                        if answer.state != .recording {
                            //if mode == .melodyPlay || mode == .rhythmEchoClap {
//                          let lname = mode == .melodyPlay ? "melody" : "rhythm"
                            let uname = mode == .melodyPlay ? "Melody" : "Rhythm"
                            
                            if mode == .melodyPlay || mode == .rhythmEchoClap {
                                PracticeToolView(text: "You can adjust the metronome at the top of the page to hear the given melody at varying tempi.")
                            }

                            PlayRecordingView(buttonLabel: "Hear The Given \(uname)",
                                              score: score,
                                              metronome: metronome,
                                              onDone: {rhythmHeard = true})
                            if mode == .melodyPlay {
                                PracticeToolView(text: "Tap the picture of the metronome in the top left corner to practise along with the tick.")
                            }
                        }

                        VStack {
                            if answer.state != .recording {
                                //if rhythmHeard {
                                    Text(self.getInstruction(mode: self.mode))
                                        .lineLimit(nil)
                                        //.padding()
                                //}

                                Button(action: {
                                    answer.setState(.recording)
                                    metronome.stopTicking()
                                    if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                                        self.isTapping = true
                                        tapRecorder.startRecording(metronomeLeadIn: false)
                                    } else {
                                        audioRecorder.startRecording(outputFileName: contentSection.name)
                                    }
                                }) {
                                    Text(answer.state == .notEverAnswered ? "Start Recording" : "Redo Recording")
                                        .foregroundColor(.white).padding().background(rhythmHeard || mode == .melodyPlay ? Color.blue : Color.gray).cornerRadius(UIGlobals.buttonCornerRadius).padding()
                                        .onAppear() {
                                            tappingView = TappingView(isRecording: $isTapping, tapRecorder: tapRecorder)
                                        }
                                }
                                .disabled(!rhythmHeard && mode != .melodyPlay)
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
                                }//.padding()
                            }
  
                            if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                                VStack {
                                    tappingView
                                }
                                //.border(Color .red)
                                .padding()
                            }

                            if answer.state == .recorded {
                                PlayRecordingView(buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                                  score: mode == .melodyPlay ? nil : getStudentScoreWithTempo(),
                                                  metronome: self.metronome,
                                                  onStart: ({
                                                        if mode != .melodyPlay {
                                                            if let recordedTempo = getStudentScoreWithTempo().recordedTempo {
                                                                metronome.setTempo(tempo: recordedTempo, context:"start hear student")
                                                            }
                                                        }
                                                    }),
                                                  onDone: ({
                                                        //recording was played at the student's tempo and now reset metronome
                                                        metronome.setTempo(tempo: self.questionTempo, context: "end hear student")
                                                    })
                                                  )

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
                        }
                        //Text(audioRecorder.status).padding()
                        if logger.status.count > 0 {
                            Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
                        }
                    }
                    .onAppear() {
                        score.setHiddenStaff(num: 1)
                        metronome.setTempo(tempo: 90, context: "View init")
                        if mode == .rhythmEchoClap || mode == .melodyPlay {
                            metronome.setAllowTempoChange(allow: true)
                        }
                        else {
                            metronome.setAllowTempoChange(allow: false)
                        }
                    }
                }
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFontSize : UIFont.systemFontSize * 1.6))
                //.navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
            //}
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
    let questionTempo = 90

    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayAnswerView(contentSection:contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode, refresh:(() -> Void)? = nil) {
        self.answer = answer
        self.score = score
        self.mode = mode
        self.metronome = Metronome.getMetronomeWithCurrentSettings(ctx:"ClapPlay Answer mode")
        metronome.speechEnabled = self.speechEnabled
        self.onRefresh = refresh
    }
        
    func analyseStudentRhythm() {
        let rhythmAnalysis = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, questionScore: score)
        self.tappingScore = rhythmAnalysis
        //let recordedTempo = rhythmAnalysis.recordedTempo
        if let tappingScore = tappingScore {
            let errorsExist = score.markupStudentScore(questionTempo: self.questionTempo, scoreToCompare: tappingScore, allowTempoVariation: mode != .rhythmEchoClap)
            self.answerWasCorrect = !errorsExist
            if errorsExist {
                self.metronome.setTempo(tempo: self.questionTempo, context: "Analyse Student - failed")
                self.metronome.setAllowTempoChange(allow: false)
            }
            else {
                if let recordedTempo = rhythmAnalysis.recordedTempo {
                    self.metronome.setTempo(tempo: recordedTempo, context: "Analyse Student - passed")
                }
                self.metronome.setAllowTempoChange(allow: true)
            }
            tappingScore.label = "Your Rhythm"
        }
    }

    var body: AnyView {
        AnyView(
            //GeometryReader { geo in
                VStack {
                    if UIDevice.current.userInterfaceIdiom != .phone {
                        if mode != .melodyPlay {
                            ToolsView(score: score)
                        }
                    }
                    ScoreView(score: score, screenWidth: UIScreen.main.bounds.width).padding()
                    if let tappingScore = self.tappingScore {
                        ScoreView(score: tappingScore, screenWidth: UIScreen.main.bounds.width).padding()
                    }
                    
                    VStack {
                        PlayRecordingView(buttonLabel: "Hear The Given \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                          score: score,
                                          metronome: metronome)

                        if mode == .melodyPlay {
                            PlayRecordingView(buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                              score: nil,
                                              metronome: metronome)
                        }
                        else {
                            if let tappingScore = self.tappingScore {
                                PlayRecordingView(buttonLabel: "Hear Your \(mode == .melodyPlay ? "Melody" : "Rhythm")",
                                                  score: tappingScore,
                                                  metronome: metronome)
                            }
                        }
                        
                        Button(action: {
                            if let refresh = self.onRefresh {
                                refresh()
                            }
                        }) {
                            Text("Try Again").foregroundColor(.white).padding().background(Color.blue).cornerRadius(UIGlobals.cornerRadius).padding()
                        }
                    }

                    //Text(audioRecorder.status).padding()
//                    if logger.status.count > 0 {
//                        Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
//                    }
                }
                .onAppear() {
                    if mode == .rhythmVisualClap || mode == .rhythmEchoClap {
                        analyseStudentRhythm()
                    }
//                    if mode == .melodyPlay {
//                        if let timeSlice = score.getLastTimeSlice() {
//                            timeSlice.addTonicChord()
//                            timeSlice.setTags(high: score.key.keySig.accidentalCount > 0 ? "G" : "C", low: "I")
//                        }
//                    }
                }
                .onDisappear() {
                    score.clearTaggs() //clear tags from any previous attempt
                }
            //}
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
