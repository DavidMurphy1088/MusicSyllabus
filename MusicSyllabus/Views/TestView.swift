import SwiftUI
import CoreData

//struct ContentView1: View {
//    let array = [1, 2, 3]
//    @State private var positions: [Int: CGRect] = [:]
//
//    var body: some View {
//        ZStack {
//            HStack(spacing: 20) {
//                ForEach(array, id: \.self) { element in
//                    Text("\(element)")
//                        .background(GeometryReader { geometry in
//                            Color.clear
//                                .onAppear {
//                                    // Store the position in the @State variables
//                                    storePosition(id: element, rect: geometry.frame(in: .global))
//                                }
//                        })
//                }
//            }
//
//            SecondChildView(positions: positions)
//        }
//    }
//
//    private func storePosition(id: Int, rect: CGRect) {
//        positions[id] = rect
//        print(positions)
//    }
//}
//
//struct SecondChildView: View {
//    @State var positions: [Int: CGRect]// = [:]
//
//    var body: some View {
//        VStack {
//            Text("Second Child View")
//
//            Button(action: {
//                print("Positions:", positions)
//            }) {
//                Text("Print Positions")
//            }
//        }
//        .onAppear {
//            // Copy the positions from the ContentView
//            //positions = (UIApplication.shared.delegate as? AppDelegate)?.contentViewPositions ?? [:]
//        }
//        .onDisappear {
//            // Store the positions in the AppDelegate for access from ContentView
//            //(UIApplication.shared.delegate as? AppDelegate)?.contentViewPositions = positions
//        }
//    }
//}
//extension AppDelegate {
//    var contentViewPositions: [Int: CGRect]? {
//        get {
//            return objc_getAssociatedObject(self, &contentViewPositionsKey) as? [Int: CGRect]
//        }
//        set {
//            objc_setAssociatedObject(self, &contentViewPositionsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
//
//private var contentViewPositionsKey: UInt8 = 0
//
//========================================================

struct TestView: View {
    var score:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)

    init () {
        let data = ExampleData.shared
        let exampleData = data.get(contentSection: ContentSection(parent: nil, type: .example, name: "test"))

        let staff = Staff(score: score, type: .treble, staffNum: 0, linesInStaff: 5)
        self.score.setStaff(num: 0, staff: staff)
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = self.score.addTimeSlice()
                    let note = entry as! Note
                    note.isOnlyRhythmNote = true
                    timeSlice.addNote(n: note)
                }
                if entry is TimeSignature {
                    let ts = entry as! TimeSignature
                    score.timeSignature = ts
                }
                if entry is BarLine {
                    //let bl = entry as! BarLine
                    score.addBarLine()
                }
                if score.scoreEntries.count > 200 {
                    break
                }
            }
        }
        score.addStemCharaceteristics()
    }
    
    var body: some View {
        //GeometryReader { geometry in
        VStack {
            Text("--Test View--")
            MetronomeView()
            ScoreView(score: score)
            //ContentView1()
        }
        //ContentView1()
        //}
    }
}

//======================


//class PositionStore: ObservableObject {
//    @Published var positions: [Int: CGRect] = [:]
//
//    func storePosition(id: Int, rect: CGRect) {
//        positions[id] = rect
//    }
//}
//
//struct ContentView1: View {
//    let array = [1, 2, 3]
//    @StateObject private var positionStore = PositionStore()
//
//    var body: some View {
//        ZStack {
//            HStack(spacing: 20) {
//                ForEach(array, id: \.self) { element in
//                    Text("\(element)")
//                        .background(GeometryReader { geometry in
//                            Color.clear
//                                .onAppear {
//                                    positionStore.storePosition(id: element, rect: geometry.frame(in: .global))
//                                }
//                        })
//                }
//            }
//
//            SecondChildView(positionStore: positionStore)
//        }
//    }
//}
//
//struct SecondChildView: View {
//    @ObservedObject var positionStore: PositionStore
//
//    var body: some View {
//        VStack {
//            Text("Second Child View")
//
//            Button(action: {
//                print("Positions:", positionStore.positions)
//            }) {
//                Text("Print Positions")
//            }
//        }
//    }
//}
//
