import SwiftUI
import CoreData

struct ConfigurationView: View {
    @Binding var isPresented: Bool
    var body: some View {
        //GeometryReader { geo in //CAUSES ALL CHILDS LEft ALIGNED???
            VStack(alignment: .center) {
                
                HStack(alignment: .center) {
                    Image("nzmeb_logo_transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                    Text("Configuration").font(.title).padding()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
                )
                .background(UIGlobals.backgroundColor)
                //.padding()
                
                ConfigSelectInstrument().padding()
                
                //ContentView2()
                Button("Cancel") {
                    isPresented = false
                }
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

                Text("Musicianship Trainer - Version.Build \(appVersion).\(buildNumber)").padding()
                
                //ContentView()
                
                VoiceListView()
            }
       // }
    }
}

struct ConfigSelectInstrument: View {
    let options = ["Piano", "Vocal", "Violin", "Guitar"]
    @State private var selectedOption: String?
    @State private var isShowingSelection = false
    
    var body: some View {
        VStack {
            //Text("Selected Option: \(selectedOption ?? "None")")
            Button("Select Instrument") {
                isShowingSelection = true
            }
            .sheet(isPresented: $isShowingSelection) {
                OptionSelectionView(selectedOption: $selectedOption)
            }
       }
    }
}

struct OptionSelectionView: View {
    let metro = Metronome.shared
    @Binding var selectedOption: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            ForEach(metro.soundFontNames.indices, id: \.self) { index in
                Button(action: {
                    metro.samplerFileName = metro.soundFontNames[index].1
                    //if let presentationMode = presentationMode {
                                presentationMode.wrappedValue.dismiss()
                            //}
                    
                }) {
                    VStack(alignment: .leading) {
                        Text("Index: \(metro.soundFontNames[index].0)")
                     }
                }
            }
        }
        .navigationTitle("Select Instrument")
    }
}

// SF2 listing

struct ContentView2: View {
    //play all instruments in an SF2
    let numbersArray:[Int] = Array(1...200)
    let metro = Metronome.shared
    let score = Score(timeSignature: TimeSignature(top: 4,bottom: 4), lines: 5)
    @State var last = 0
    
    init() {
        for i in 0...0 {
            let ts = score.addTimeSlice()
            ts.addNote(n: Note(num: Note.MIDDLE_C + 12 + 2*i))
        }
    }
    
    var body: some View {
        ScoreView(score: score)
        ScrollView {
            VStack(spacing: 10) {
                ForEach(numbersArray, id: \.self) { item in
                    Button(action: {
                        last = item
                        metro.soundFontProgram = Int(item)
                        metro.playScore(score: score)
                    }) {
                        Text("num:\(item)")
//                            .padding()
//                            .background(Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()

        Button(action: {
            metro.stopPlayingScore(note: Note.MIDDLE_C + 12)
            
        }) {
            Text("STOP").padding()
        }
    }

}
