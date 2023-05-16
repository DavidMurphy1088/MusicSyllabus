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
                    .padding()
                VStack {
                    HStack {
                        Text("Tempo \(Int(self.tempo))").padding()
                    }
                    Text(metronome.tempoName)
                }
            }
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
                Text(metronomeIsOn ? "Stop Metronome" : "Start Metronome")
            }
            .padding()
            
            Slider(value: $tempo, in: 40...220, onEditingChanged: { value in
                metronome.setTempo(tempo: tempo)
            })
            .padding()

        }
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        .padding()
    }
}




