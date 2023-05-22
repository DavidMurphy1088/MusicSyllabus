import SwiftUI

enum QuestionMode {
    case clap
    case play
    case none
}

struct ClapOrPlayPresentView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @ObservedObject var tapRecorder = TapRecorder.shared
    @ObservedObject private var logger = Logger.logger

    @State private var isAnimating = false
    @State var showBaseCleff = false

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
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: mode == .clap ? 1 : 5)

        score.setStaff(num: 0, staff: staff)
        if mode == .play {
            let bstaff = Staff(score: score, type: .bass, staffNum: 1, linesInStaff: mode == .clap ? 1 : 5)
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
                    note.setIsOnlyRhythm(way: mode == .clap ? true : false)
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
            if mode == .play && lastNote != nil {
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
            score.addBarLine()
        }
        //print("\n======ClapOrPlayView init name:", contentSection.name, "score ID:", score.id, answer.state)
    }

    func instructionText() -> String {
        let result:String
        if self.mode == .clap {
            //if self.answer.state == .notRecorded {
                result = "\n\u{25BA}   Start recording\n\u{25BA}   Tap the rhythm\n\u{25BA}   Stop recording"
//            }
//            else {
//                result = "Record your tapping again"
//            }
        }
        else {
            //if self.answer.state == .notRecorded {
                result = "\n\u{25BA}   Start recording\n\u{25BA}   Play the melody and the final chord\n\u{25BA}   Stop recording"
//            }
//            else {
//                result = "Record your playing again"
//            }
       }
        return result
    }

    var body: AnyView {
        AnyView(
        VStack {
            VStack {
                MetronomeView(metronome: metronome)
                HStack {
                    ScoreView(score: score).padding()
                }
                
                Text(audioRecorder.status).padding()
                if logger.status.count > 0 {
                    Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
                }

                VStack {
                    if answer.state != .recording {
                        ScrollView {
                            VStack(alignment: .leading) {
                                Text("Steps- \n"+self.instructionText())
                            }
                            .padding()
                        }
                        Button(action: {
                            answer.setState(.recording)
                            if self.mode == .clap {
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
                        if self.mode == .clap {
                            TappingView(tapRecorder: tapRecorder).padding()
                        }
                        
                        Image(systemName: "stop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.red)
                            .scaleEffect(isAnimating ? 1.1 : 0.9)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
                            .onAppear() {
                                self.isAnimating = true
                            }
                            .padding()
                            .onTapGesture {
                                answer.setState(.recorded)
                                if self.mode == .clap {
                                    self.tapRecorder.stopRecording()
                                }
                                else {
                                    audioRecorder.stopRecording()
                                }
                                isAnimating = false
                        }
                            
                        Button(action: {
                            answer.setState(.recorded)
                            if self.mode == .clap {
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
            }

        }
        .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFontSize : UIFont.systemFontSize * 1.6))
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
        )
    }
}

struct ClapOrPlayAnswerView: View, QuestionPartProtocol {
    @ObservedObject var answer:Answer
    @ObservedObject private var logger = Logger.logger
    @ObservedObject var audioRecorder = AudioRecorder.shared
    @State var playingCorrect = false
    @ObservedObject var tapRecorder = TapRecorder.shared
    
    private var score:Score
    private let metronome = Metronome.shared
    var mode:QuestionMode

    static func createInstance(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) -> QuestionPartProtocol {
        return ClapOrPlayAnswerView(contentSection:contentSection, score:score, answer: answer, mode: mode)
    }
    
    init(contentSection:ContentSection, score:Score, answer:Answer, mode:QuestionMode) {
        self.answer = answer
        self.score = score
        self.mode = mode
    }
    
    var body: AnyView {
        AnyView(
            VStack {
                MetronomeView(metronome: metronome)
                HStack {
                    ScoreView(score: score).padding()
                }
                if logger.status.count > 0 {
                    Text(logger.status).font(logger.isError ? .title3 : .body).foregroundColor(logger.isError ? .red : .gray)
                }

                VStack {
                    Text(audioRecorder.status).padding()

                    Button(action: {
                        if mode == .clap {
                            tapRecorder.playRecording()
                        }
                        else {
                            audioRecorder.playRecording()
                        }
                    }) {
                        Text("Hear Your \(self.mode == .clap ? "Rhythm" : "Playing")")
                            .font(.system(.body))
                    }
                    .padding()
                    
                    HStack {
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
                                Text("Hear The Correct \(self.mode == .clap ? "Rhythm" : "Playing")")
                            }
                        }
                        
                    }
                    .padding()
                }
//                .overlay(
//                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
//                )
//                .background(UIGlobals.backgroundColor)
//                .padding()
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
