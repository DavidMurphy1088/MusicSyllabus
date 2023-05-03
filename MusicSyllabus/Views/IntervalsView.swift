import SwiftUI
import CoreData


struct IntervalsView: View {
    
    var body: some View {
        VStack {
            Spacer()
            PianoKeyboard()
            Spacer()
            Button(action: {
                SoundGenerator.soundGenerator.playNote(notePitch: Note.MIDDLE_C)
            }) {
                Text("Play Sound")
            }
            Spacer()
        }
    }
}

