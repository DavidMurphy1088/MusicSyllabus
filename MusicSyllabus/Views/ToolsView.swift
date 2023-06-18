import SwiftUI
import CoreData

struct ToolsView: View {
    let score:Score
    let frameHeight = 120.0
    
    var body: some View {
        HStack {
            MetronomeView(score:score, frameHeight: frameHeight)
                //.frame(height: imageSize * 1.50)
            VoiceCounterView(frameHeight: frameHeight)
                //.frame(height: imageSize * 1.50)
        }
    }
}




