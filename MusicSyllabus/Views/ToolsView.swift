import SwiftUI
import CoreData

struct ToolsView: View {
    let score:Score
    let frameHeight = 120.0
    
    var body: some View {
        VStack {
            HStack {
                MetronomeView(score:score, frameHeight: frameHeight)
                    //.padding(.horizontal)
                    .padding()
                VoiceCounterView(frameHeight: frameHeight)
                    //.padding(.horizontal)
                    .padding()
            }
        }
    }
}




