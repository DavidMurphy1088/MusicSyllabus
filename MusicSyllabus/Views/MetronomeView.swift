import SwiftUI
import CoreData

struct MetronomeView: View {
    let score:Score
    var frameHeight:Double
    
    @ObservedObject var metronome = Metronome.getMetronomeWithCurrentSettings()
    //@State var metronomeIsOn = false
    //@State private var isSwitchedOn = false
    
    var body: some View {
        VStack {
            //VStack {
                HStack {
                    Button(action: {
                        if metronome.tickingIsActive == false {
                            metronome.startTicking(score: score)
                        }
                        else {
                            metronome.stopTicking()
                        }
                    }, label: {
                        Image("metronome")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: frameHeight / 2.0)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(metronome.tickingIsActive ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .padding()
                    })

                    Image("note_transparent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: frameHeight / 6.0)
                    Text("=\(Int(metronome.tempo)) BPM")
                //}
                //HStack {
                    Text(metronome.tempoName).padding()
                    //}
                    //.padding()
                    
                    if metronome.allowChangeTempo {
                        Slider(value: Binding<Double>(
                            get: { Double(metronome.tempo) },
                            set: {
                                metronome.setTempo(tempo: Int($0))
                            }
                        ), in: Double(metronome.tempoMinimumSetting)...Double(metronome.tempoMaximumSetting), step: 1)
                        .padding()
                    }
                //}
            }

        }
        .frame(height: frameHeight)
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        .padding()
    }
}




