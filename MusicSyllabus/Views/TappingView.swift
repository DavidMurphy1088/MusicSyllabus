import SwiftUI
import CoreData

enum TapState {
    case inactive
    case active(location: CGPoint)
}

struct TappingView: View {
    @State var tempo = Metronome.shared.tempo
    @GestureState private var tapState = TapState.inactive
    @State private var tapRecords: [CGPoint] = []
    @State var ctr = 0
    
    @State private var message = "Message"
    let newGesture = TapGesture().onEnded {
        print("Tap on VStack.")
    }

    var body: some View {
        VStack(spacing:25) {
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 75, height: 75)
                .padding()
                .foregroundColor(.red)
                .onTapGesture {
                    print("Tap on image.")
                }
                Rectangle()
                    .fill(Color.blue)
        }
        .gesture(newGesture)
        .frame(width: 200, height: 200)
        .border(Color.purple)
    }
//        .overlay(
//            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
//        )
//        .background(UIGlobals.backgroundColor)
}





