import SwiftUI
import CoreData

struct MetronomeView: View {
    @ObservedObject var metronome = Metronome.getMetronomeWithCurrentSettings()
    @State var metronomeIsOn = false
    let imageSize = 60.0
    
    init () {
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("metronome")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .padding()
                
                Button(action: {
                    metronomeIsOn.toggle()
                    if metronomeIsOn {
                        metronome.isTickingWithScorePlay = true
                    }
                    else {
                        metronome.isTickingWithScorePlay = false
                    }
                }) {
                    //Text(metronomeIsOn ? "Stop Metronome" : "Start Metronome")
                    Text(metronomeIsOn ? "Is On" : "Is Off")
                }
                .padding()
//                .onAppear(perform: {
//                    tempo = metronome.tempo
//                })

                //VStack {

                    Text("Tempo:").padding()
                    Image("note_transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize / 3.0)
                    Text(" =  \(Int(metronome.tempo)) BPM")
                
                Text("  ")
                Text(metronome.tempoName).padding()
                //}
                //.padding()
                
                if metronome.allowChangeTempo {
                    //                Slider(value: $tempo, in: Double(metronome.tempoMinimumSetting)...Double(metronome.tempoMaximumSetting), onEditingChanged: { value in
                    //                    metronome.setTempo(tempo: tempo)
                    //                })
                    Slider(value: Binding<Double>(
                        get: { Double(metronome.tempo) },
                        set: {
                            metronome.setTempo(tempo: Int($0))
                        }
                    ), in: Double(metronome.tempoMinimumSetting)...Double(metronome.tempoMaximumSetting), step: 1)
                    .padding()
                }
            }

        }
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        .padding()
    }
}




