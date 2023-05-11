import SwiftUI
import CoreData
import AVFoundation

struct RhythmsAnswerView:View {
    @State var score:Score
    @State var metronome = Metronome.shared
    let imageSize = Double(32)
    @Binding var answered:RhythmsView.AnswerState
    var audioPlayer:AudioFilePlayer = AudioFilePlayer()
    
    var explanation = ""
    
    func playAnswer() {
    }
    
    var body: some View {
        VStack {
            Button(action: {
                audioPlayer.playFile()
            }) {
                Text("Hear Your Rhythm")
            }
            Spacer()
            Button(action: {
                metronome.playScore(score: score)
            }) {
                Text("Hear The Test Rhythm")
            }
            Spacer()

            Button(action: {
                answered = RhythmsView.AnswerState.notRecorded
            }) {
                Text("Next Questioon")
            }
            Spacer()
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
            .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
        )
        .padding()
        Spacer()
    }
}


struct RhythmsView:View {
    @State var exampleName:String = ""
    @State var metronome = Metronome.shared
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 1)
    @State var answerState:AnswerState = .notRecorded
    @State private var isAnimating = false

    var audioRecorder = AudioRecorder()
    let exampleData = ExampleData.shared

    enum AnswerState {
        case notRecorded
        case recording
        case recorded
        case submittedAnswer
    }
    
    init(contentSection:ContentSection) {
        //let exampleNum = Int(exampleNum)
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 1)
        score.setStaff(num: 0, staff: staff)
        //let vx = [2,2,0,1,1,2,0,1,1,2,0,4]
        let questionData = exampleData.get(contentSection.name)
        if let questionData = questionData {
            let questionData = questionData.split(separator: ",")
            var n = Note.MIDDLE_C + Note.OCTAVE - 1
            for v in questionData {
                let vn = Int(v)
                if vn! > 0 {
                    let note = Note(num: n, value: vn)
                    note.isOnlyRhythmNote = true
                    score.addTimeSlice().addNote(n: note)
                }
                else {
                    score.addBarLine()
                }
            }
        }
        score.addBarLine()
    }
    
    var body: some View {
        VStack {
            VStack {
                if answerState == AnswerState.submittedAnswer {
                    Spacer()
                }
                HStack {
                    ScoreView(score: score).padding()
                }
                MetronomeView(metronome: metronome)
                
                HStack {
                    Spacer()
                    if answerState == AnswerState.notRecorded || answerState == AnswerState.recorded {
                        Button(action: {
                            answerState = .recording
                            audioRecorder.startRecording()
                        }) {
                            Text("Record Your Rhythm")
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
                        }) {
                            Text("Check Your Answer")
                        }
                        .padding()
                    }

                    Spacer()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
                )
                .padding()
            }

            
            if answerState == AnswerState.submittedAnswer {
                RhythmsAnswerView(score: score, metronome: metronome, answered: $answerState)
            }
        }
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
    }
}

