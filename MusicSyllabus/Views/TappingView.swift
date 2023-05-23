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
    @State var tapRecorder:TapRecorder
    @State var tempo = Metronome.shared.tempo
    @GestureState private var tapState = TapState.inactive
    @State private var tapRecords: [CGPoint] = []
    @State var ctr = 0
    @ObservedObject var invert:Invert = Invert()

    var body: some View {
        VStack {
            Text("Tap the drum").padding()
            Image("drum")
                .resizable()
                .scaledToFit()
                .foregroundColor(invert.invert ? .blue : .red)
                //.frame(width: getSize(w: geo.size.height, h: geo.size.height), height: geo.size.height/4)
                //.frame(width: 30, height: 30)
                .border(invert.invert ? Color.accentColor : Color.black, width: invert.invert ? 2 : 4)
                .onTapGesture {
                    invert.rev()
                    tapRecorder.makeTap()
                }
        }
    }
}





