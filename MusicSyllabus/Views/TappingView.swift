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
        //GeometryReader { geo in
        VStack {
            Text("Tap the drum").padding()
            VStack(spacing:25) {
                Image("drum")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(invert.invert ? .blue : .red)
                
                //.frame(width: 200, height: 200)
                //.frame(width: geo.size.width * 0.75)
                //.rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800)) // Mark 4
                //.scaleEffect(secondAnimation ? 0 : 1) // Mark 4
                //.offset(y: secondAnimation ? 400 : 0) // Mark 4
                //.opacity(imageOpacity)
                    //.border(Color(invert.invert ? .blue : .black), width: 4)
                    .border(invert.invert ? Color.accentColor : Color.black, width: invert.invert ? 8 : 4)
                //Rectangle()
                //.fill(Color.blue)
                    .onTapGesture {
                        //print(invert.invert)
                        invert.rev()
                        tapRecorder.clap()
                    }
            }
        }
        //}
//        .overlay(
//            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
//        )
//        .background(UIGlobals.backgroundColor)
    }

}





