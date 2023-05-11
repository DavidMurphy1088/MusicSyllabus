import SwiftUI
import CoreData

struct MetronomeView: View {
    @ObservedObject var metronome = Metronome.shared
    @State var tempo = Metronome.shared.tempo
    @State var metronomeIsOn = false
    
    var body: some View {
        VStack {
            HStack {
                Image("metronome")
                    .resizable()
                    .frame(width: 60, height: 60)
                    //.padding()
            }
            HStack {
                VStack {
                    Text(metronome.tempoName)
                    HStack {
                        Text("Tempo \(Int(self.tempo))").padding()
                        Slider(value: $tempo, in: 40...200, onEditingChanged: { value in
                            metronome.setTempo(tempo: tempo)
                        })
                        .padding()
                    }
                }
            }
            HStack {
                Button(action: {
                    metronomeIsOn.toggle()
                    if metronomeIsOn {
                        metronome.setTempo(tempo: tempo)
                        metronome.startTicking()
                    }
                    else {
                        metronome.stopTicking()
                    }
                }) {
                    Text(metronomeIsOn ? "Stop" : "Start")
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
        )
        .padding()
    }
}




