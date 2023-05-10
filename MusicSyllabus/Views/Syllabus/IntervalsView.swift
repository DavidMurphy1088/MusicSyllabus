import SwiftUI
import CoreData

struct IntervalsAnswerView:View {
    @State var metronome = Metronome.shared
    var score:Score
    var correct:Bool
    var correctAnswer:String
    let imageSize = Double(32)
    @Binding var answered:IntervalsView.AnswerState
    
    var explanation = "A line to a space is a step (second interval), a space to line is a step (second interval), a line to a line is a skip (third interval) and a space to space is skip (third interval)."
    
    var body: some View {
        VStack {
            HStack {
                if correct {
                    Image(systemName: "checkmark.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.green)
                    Text("Correct")
                }
                else {
                    Image(systemName: "staroflife.circle").resizable().frame(width: imageSize, height: imageSize).foregroundColor(.red)
                    Text("Not correct")
                }
            }
            .padding()
            Text("The interval is a \(correctAnswer)").padding()
            Text(explanation).italic().padding()
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
    @State var metronome = Metronome.shared
    @State var exampleNum:Int
    @State var score:Score = Score(timeSignature: TimeSignature(), lines: 5)
    @State private var selectedAnswer: String? = nil
    @State private var answerState:AnswerState = .notAnswered
    
    @State private var selectedOption = 0
    let options = ["Second", "Third"]
    
    enum AnswerState {
        case notAnswered
        case selectedAnAnswer
        case submittedAnswer
    }
    
    init(exampleNum:Int, questionData:String?) {
        self.exampleNum = exampleNum
        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        score.setStaff(num: 0, staff: staff)
        if let questionData = questionData {
            let notes = questionData.split(separator: ",")
            let n1 = Int(notes[0])
            var ts = score.addTimeSlice()
            ts.addNote(n: Note(num: n1!, value: Note.VALUE_HALF))

            let n2 = Int(notes[1])
            ts = score.addTimeSlice()
            ts.addNote(n: Note(num: n2!, value: Note.VALUE_HALF))
            ts = score.addTimeSlice()
            ts.addNote(n: Note(num: n2!, value: Note.VALUE_HALF))
            ts.score.addBarLine(atScoreEnd: true)
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    ScoreView(score: score).padding()
                }
                
                HStack {
                    Text("Please choose the correct interval type").padding()
                    Picker("Select an option", selection: $selectedOption) {
                        ForEach(options.indices, id: \.self) { index in
                            Text(options[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: selectedOption) { newValue in
                        print("Selection changed to index \(newValue)")
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
                IntervalsAnswerView(metronome: metronome, score: score, correct: selectedOption == 0, correctAnswer: options[0], answered: $answerState)
            }
        }
        .navigationBarTitle("Visual Interval", displayMode: .inline).font(.subheadline)
    }
}

