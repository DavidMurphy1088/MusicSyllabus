import SwiftUI
import CoreData

struct ToolsView: View {
    let score:Score
    let frameHeight = 120.0

//    init () {
//    }
    
    var body: some View {
        HStack {
            MetronomeView(score:score, frameHeight: frameHeight)
                //.frame(height: imageSize * 1.50)
            VoiceCounterView(frameHeight: frameHeight)
                //.frame(height: imageSize * 1.50)
        }
//        .overlay(
//            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
//        )
//        .background(UIGlobals.backgroundColor)
//        .padding()
    }
}




