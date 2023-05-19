import SwiftUI
import CoreData
import AVFoundation

struct RhythmsAnswerView:View {
    var mode:ClapOrPlay.Mode
    @ObservedObject var audioRecorder:AudioRecorder
    @State var score:Score
    @State var metronome = Metronome.shared
    @State var playingCorrect = false
    let imageSize = Double(32)
    @Binding var answered:ClapOrPlay.AnswerState
    
    var explanation = ""
    
    var body: some View {
        VStack {
            Button(action: {
                audioRecorder.playRecording()
            }) {
                Text("Hear Your \(self.mode == .clap ? "Rhythm" : "Playing")")
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

//            Button(action: {
//                answered = ClapOrPlay.AnswerState.notRecorded
//            }) {
//                Text("Next Questioon")
//            }
//            .padding()
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        
        .background(UIGlobals.backgroundColor)
        .padding()        
    }
}

struct ClapOrPlay:View {
    var mode:ClapOrPlay.Mode
    var score:Score
    var staff:Staff
    let contentSection:ContentSection

    let metronome = Metronome.shared
    @State var answerState:AnswerState = .notRecorded
    @State private var isAnimating = false
    @State var showBaseCleff = false
    let logger = Logger.logger
    let exampleData = ExampleData.shared
    
    @ObservedObject var audioRecorder = AudioRecorder.shared
    //@ObservedObject var audioStatus = AudioRecorder.shared.status
    
    @State var exampleName:String = ""
    
    enum Mode {
        case clap
        case play
    }

    enum AnswerState {
        case notRecorded
        case recording
        case recorded
        case submittedAnswer
    }
    
    init(mode:ClapOrPlay.Mode, contentSection:ContentSection) {
        self.mode = mode
        self.score = Score(timeSignature: TimeSignature(), lines: 1)
        self.contentSection = contentSection
        staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: mode == .clap ? 1 : 5)

        score.setStaff(num: 0, staff: staff)
        if mode == .play {
            let bstaff = Staff(score: score, type: .bass, staffNum: 1, linesInStaff: mode == .clap ? 1 : 5)
            score.setStaff(num: 1, staff: bstaff)
            score.hiddenStaffNo = 1
        }
        let exampleData = exampleData.get(contentSection.parent!.name, contentSection.name)
        score.setStaff(num: 0, staff: staff)
        
        var lastTS:TimeSlice? = nil
        
        if false {
            let timeSlice = score.addTimeSlice()
            var n = Note.MIDDLE_C - Note.OCTAVE
            timeSlice.addNote(n: Note(num: n))
            timeSlice.addNote(n: Note(num: n + 4))
        }
        else {
            if let entries = exampleData {
                for entry in entries {
                    if entry is Note {
                        let timeSlice = score.addTimeSlice()
                        let note = entry as! Note
                        note.staff = 0
                        note.setIsOnlyRhythm(way: mode == .clap ? true : false)
                        timeSlice.addNote(n: note)
                        lastTS = timeSlice
                    }
                    if entry is BarLine {
                        score.addBarLine()
                    }
                }
                if mode == .play {
                    lastTS?.tag = "I"
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE, staff: 1))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE + 4, staff: 1))
                    //lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE))
                    lastTS?.addNote(n: Note(num: Note.MIDDLE_C - Note.OCTAVE + 7, staff: 1))
                }
//                let timeSlice = score.addTimeSlice()
//                var n = Note.MIDDLE_C + Note.OCTAVE
//                timeSlice.addNote(n: Note(num: n, value: 1))
            }
        }
        //score.addBarLine(atScoreEnd: true)
    }
    
    func instructionText() -> String {
        let result:String
        if self.mode == .clap {
            if self.answerState == .notRecorded {
                result = "Please record your tapping to see the correct answer"
            }
            else {
                result = "Record your tapping again"
            }
        }
        else {
            if self.answerState == .notRecorded {
                result = "\n\u{25BA}   Start recording\n\u{25BA}   Play the melody and the final chord\n\u{25BA}   Stop recording"
            }
            else {
                result = "Record your playing again"
            }
       }
        return result
    }

    var body: some View {
        VStack {
            VStack {
                MetronomeView(metronome: metronome)
                HStack {
                    ScoreView(score: score).padding()
                }

                VStack {
                    if answerState == .notRecorded || answerState == .recorded {
                        if answerState == .notRecorded {
                            Text(self.instructionText()).padding()
                        }
                        Button(action: {
                            answerState = .recording
                            audioRecorder.startRecording()
                        }) {
                            Text(answerState == .notRecorded ? "Start Recording" : "Redo Recording")
                        }
                        .padding()
                    }

                    if answerState == AnswerState.recording {
                        HStack {
                            Image("microphone")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .scaleEffect(isAnimating ? 1.1 : 0.9)
                                .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true))
                                .onAppear() {
                                    self.isAnimating = true
                                }
                                .padding()
                            Button(action: {
                                answerState = .recorded
                                audioRecorder.stopRecording()
                                isAnimating = false
                            }) {
                                Text("Stop Recording")
                            }.padding()
                        }
                    }
                    if answerState == AnswerState.recorded {
                        Button(action: {
                            answerState = .submittedAnswer
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

            if answerState == AnswerState.submittedAnswer {
                RhythmsAnswerView(mode: mode, audioRecorder: audioRecorder, score: score, metronome: metronome, answered: $answerState)
            }
            
            Text(audioRecorder.status).padding()
            
            if logger.status != nil {
                Text(logger.status!).font(.caption).foregroundColor(logger.isError ? .red : .gray)
            }

        }
        .font(.system(size: UIDevice.current.userInterfaceIdiom == .phone ? UIFont.systemFontSize : UIFont.systemFontSize * 1.6))
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
    }
}

//override func viewDidLoad() {
//    super.viewDidLoad()
//    requestMicrophonePermission()
//    // Additional code for setting up your view or performing other tasks
//}