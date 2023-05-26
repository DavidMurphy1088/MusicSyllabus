import SwiftUI
import CoreData

enum TapState {
    case inactive
    case active(location: CGPoint)
}
class Invert : ObservableObject {
    @Published var invert = true
    func rev() {
        DispatchQueue.main.async {
            self.invert.toggle()
        }
    }
}

struct TappingView: View {
    @Binding var isRecording:Bool
    @State var tapRecorder:TapRecorder

    @State var tempo = Metronome.shared.tempo
    @State private var tapRecords: [CGPoint] = []
    @State var ctr = 0
    @ObservedObject var invert:Invert = Invert()
    
    func scaleEffect() -> Double {
        let effect = isRecording ? 2.0 : 0.0
        print("Scale effect", isRecording, effect)
        return effect
    }
    
    func test() -> Bool {
        print("animation value()", isRecording)
        return isRecording
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Tap the rhythm")//.padding()
                Text("on the drum")//.padding()

//                Button(action: {
//                    self.isRecording.toggle()
//                }) {
//                    Text("Recording??? \(String(self.isRecording))")
//                }

                ZStack {
                    
                    Image("drum")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(invert.invert ? .blue : .red)
                        .frame(width: geometry.size.width / 4.0)
                        .border(invert.invert ? Color.accentColor : Color.black, width: invert.invert ? 2 : 8)
                        .padding()
                    
                    //Give up after hours trying to make this shit work. The animation enver stops
                    if isRecording {
                        Image(systemName: "stop.circle")
                            .resizable()
                        //.scaledToFit()
                            .foregroundColor(Color.red)
                            .frame(width: geometry.size.width / 10.0, height: geometry.size.height / 10.0)
                        //.scaleEffect(scaleEffect())
                        //.animation(.easeOut(duration: 1.0).repeatForever(), value: isRecording)
                        //.animation(.easeOut(duration: 1.0).repeatForever(), value: test())
                    }
                }
                    
                }
            .frame(width: geometry.size.width)
            .onTapGesture {
                invert.rev()
                tapRecorder.makeTap()
            }

            }

            //.padding()
            //.border(.red)
       }
    

}





