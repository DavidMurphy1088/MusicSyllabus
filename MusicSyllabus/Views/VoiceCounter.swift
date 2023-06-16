import SwiftUI
import CoreData

struct VoiceCounterView: View {
    var frameHeight:Double
    @State private var isSwitchedOn = false

    var body: some View {
        VStack {
            Button(action: {
                isSwitchedOn.toggle()
            }, label: {
                Image("voiceCount")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: frameHeight / 2.0)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: isSwitchedOn ? 10 : 0)
                            .stroke(isSwitchedOn ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .padding()
                    //.border(isImagePressed ? Color.red : Color.clear, width: 2)
            })

         }
        .frame(height: frameHeight)
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        .padding()
    }
}




