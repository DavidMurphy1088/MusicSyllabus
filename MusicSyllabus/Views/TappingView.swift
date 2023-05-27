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
    @ObservedObject var tapRecorder:TapRecorder
    @State var metronome = Metronome.shared
    @State private var tapRecords: [CGPoint] = []
    @State var ctr = 0
    @ObservedObject var invert:Invert = Invert()
    @State private var isScaled = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Image("drum")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(invert.invert ? .blue : .red)
                        .frame(width: geometry.size.width / 4.0)
                        .border(invert.invert ? Color.accentColor : Color.black, width: invert.invert ? 2 : 8)
                        .padding()
                    
                    if isRecording {
                        if tapRecorder.enableRecordingLight {
//                            Image(systemName: "stop.circle")
//                            .resizable()
//                            //.scaledToFit()
//                            .foregroundColor(Color.red)
//                            .frame(width: geometry.size.width / 10.0, height: geometry.size.height / 10.0)
//                            .scaleEffect(scaleEffect())
//                            .animation(.easeOut(duration: 1.0).repeatForever(), value: isRecording)
//                            //.animation(.easeOut(duration: 1.0).repeatForever(), value: test())
                            
                            Image(systemName: "stop.circle")
                                .foregroundColor(Color.red)
                                .font(.system(size: isScaled ? 70 : 50))
                                .animation(Animation.easeInOut(duration: 1.0).repeatForever()) // Animates forever
                                .onAppear {
                                    self.isScaled.toggle()
                                }
                        }
                    }
                }
                    
                }
            .frame(width: geometry.size.width)
            .onTapGesture {
                if isRecording {
                    invert.rev()
                    tapRecorder.makeTap()
                }
            }

            }

            //.padding()
            //.border(.red)
       }
    

}





