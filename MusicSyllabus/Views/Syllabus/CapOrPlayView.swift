import SwiftUI

enum QuestionMode {
    //intervals
    case intervalVisual
    case intervalAural
    
    //rhythms
    case rhythmClap
    case rhythmPlay
    
    case none
}

struct ClapOrPlayPresentView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject private var logger = Logger.logger

    @State private var isAnimating = false
    @State var showBaseCleff = false
    @State private var helpPopup = false
    
    //WARNING - Making Score a @STATE makes instance #1 of this struct pass its Score to instance #2
    var score:Score
    let exampleData = ExampleData.shared
    var contentSection:ContentSection
    let metronome = Metronome.shared
    var mode:QuestionMode
     
    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayPresentView(contentSection: contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.contentSection = contentSection
        self.mode = mode
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: mode == .rhythmClap ? 1 : 5)

        score.setStaff(num: 0, staff: staff)
        if mode == .rhythmPlay {
            let bstaff = Staff(score: score, type: .bass, staffNum: 1, linesInStaff: mode == .rhythmClap ? 1 : 5)
            score.setStaff(num: 1, staff: bstaff)
            score.hiddenStaffNo = 1
        }
        let exampleData = exampleData.get(contentSection: contentSection) //(contentSection.parent!.name, contentSection.name)
        score.setStaff(num: 0, staff: staff)
        
        var lastTS:TimeSlice? = nil
        var lastNote:Note? = nil
        
//        score.addTimeSlice().addNote(n: Note(num: Note.MIDDLE_C - 12, value: 3, staff:1, isDotted: true))
//        score.addTimeSlice().addNote(n: Note(num: Note.MIDDLE_C + 2, value: 3, staff:1, isDotted: true))
//        return
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = score.addTimeSlice()
                    let note = entry as! Note
                    note.staff = 0
                    note.setIsOnlyRhythm(way: mode == .rhythmClap ? true : false)
                    //note.value = 1
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
            //score.addBarLine()
        }
        //print("\n======ClapOrPlayView init name:", contentSection.name, "score ID:", score.id, answer.state)
    }

    func instructionText() -> String {
        let result:String
        if self.mode == .rhythmClap {
            result = "\n\u{25BA}   Start recording\n\u{25BA}   Tap your rhythm on the drum that appears\n\u{25BA}   Stop the recording"
        }
        else {
            result = "\n\u{25BA}   Start recording\n\u{25BA}   Play the melody and the final chord\n\u{25BA}   Stop the recording"
       }
        return result
    }

    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
                VStack {
                    VStack {
                        MetronomeView(metronome: metronome)
                        HStack {
                            ScoreView(score: score).padding()
                        }
                        
                        VStack {
                            if answer.state != .recording {
                                Button(action: {
                                        helpPopup = true
                                    }) {
                                        Image(systemName: "questionmark.circle.fill").font(.system(size: 24)).padding()
                                    }
                                    .popover(isPresented: $helpPopup, arrowEdge: .top) {
                                        HelpView(helpInfo: self.instructionText())
                                            .padding()
                                    }
                                
                                Button(action: {
                                    answer.setState(.recording)
                                    if self.mode == .rhythmClap {
                                        tapRecorder.startRecording()
                                    } else {
                                        audioRecorder.startRecording()
                                    }
                                }) {
                                    Text(answer.state == .notEverAnswered ? "Start Recording" : "Redo Recording")
                                }
                                .padding()
                            }
                            
                            if answer.state == .recording {
                                if self.mode == .rhythmClap {
                                    TappingView(tapRecorder: tapRecorder).padding()
                                        .frame(width: geometry.size.width/4, height: geometry.size.height/4)
                                }
                                
                                Image(systemName: "stop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width/10, height: geometry.size.height/10)
                                    .foregroundColor(Color.red)
                                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                                    .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
                                    .onAppear() {
                                        self.isAnimating = true
                                    }
                                    .padding()
                                    .onTapGesture {
                                        answer.setState(.recorded)
                                        if self.mode == .rhythmClap {
                                            self.tapRecorder.stopRecording()
                                        }
                                        else {
                                            audioRecorder.stopRecording()
                                        }
                                        isAnimating = false
                                    }
                                
                                Button(action: {
                                    answer.setState(.recorded)
                                    if self.mode == .rhythmClap {
                                        self.tapRecorder.stopRecording()
                                    }
                                    else {
                                        audioRecorder.stopRecording()
                                    }
                                    isAnimating = false
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
    @ObservedObject var answer:Answer
    @ObservedObject private var logger = Logger.logger
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @State var playingCorrect = false
    @State var playingStudent = false
    
    @ObservedObject var tapRecorder = TapRecorder.shared
    
    private var score:Score
    @State var tappingScore:Score?
    
    private let metronome = Metronome.shared
    var mode:QuestionMode

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
    }
    
    var body: AnyView {
        AnyView(
            GeometryReader { geometry in
            VStack {
                MetronomeView(metronome: metronome)
                VStack {
                    ScoreView(score: score).padding()
                    if tappingScore != nil {
                        ScoreView(score: tappingScore!).padding()
                    }
                }
                
                HStack {
                    VStack {
                        // Hear correct
                        Button(action: {
                            metronome.playScore(score: score, onDone: {
                                playingCorrect = false
                            })
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
                                Text("Hear The Correct \(self.mode == .rhythmClap ? "Rhythm" : "Playing")")
                                    .buttonStyle(DefaultButtonStyle())
                            }
                        }
                        .padding()
                        
                        //Hear user rhythm
                        Button(action: {
                            if mode == .rhythmClap {
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
                                Text("Hear Your \(self.mode == .rhythmClap ? "Rhythm" : "Playing")")
                                    .font(.system(.body))
                            }
                        }
                        .padding()
                        .onAppear {
                            if mode == .rhythmClap {
                                tappingScore = tapRecorder.analyseRhythm(timeSignatue: score.timeSignature, inputScore: score)
                                tappingScore?.label = "Your Rhythm"
                            }
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                    )
                    .background(UIGlobals.backgroundColor)
                    .padding()
                    
                    //voice on/off
                    VStack {
                        Image("talkIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width / 10.0)
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
