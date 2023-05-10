import SwiftUI
import CoreData

struct MetronomeView: View {
    @State var metronome = Metronome.shared
    @State var tempo = 60.0
    @State var metronomeIsOn = false
    
    var body: some View {
        VStack {
            HStack {
                Image("metronome")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .padding()
                
                VStack {
                    HStack {
                        Text("Tempo \(Int(self.tempo))")
                        Slider(value: $tempo, in: 40...180, onEditingChanged: { value in
                            //print("Slider value changed to: \(requiredDecibelChange)")
                            metronome.setTempo(tempo: tempo)
                        })
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
                        Text(metronomeIsOn ? "Stop" : "Start")
                    }
                }
                .padding()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
        )
        .padding()
    }
}




