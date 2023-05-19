import SwiftUI
import CoreData
import MessageUI

class BeamCounter : ObservableObject  {
    var notePositions:[(Note, CGRect)] = []
    var rotationOccured = false
    @Published var updated:Int = 0
    
    //sometimes getNotes() returns a zero length array. The below is a hack to fix this but needs correcting
    static var lastNonZeroPostions:[(Note, Note, CGRect, CGRect)] = [] //TOOD FIX!!!
    
    func add(p: (Note, CGRect)) {
        for n in notePositions { //TODO remove
            if n.0.id == p.0.id {
//                print("================== duplicated id", p.0.id)
//                if rotationOccured {
//                    self.notePositions = []
//                    self.rotationOccured = false
//                }
//                else {
                    return
                //}
            }
        }
//        if p.0.sequence == 0 {
//            print ("--------------------- new Adding COUNT:", self.notePositions.count)
//        }
        self.notePositions.append(p)
        //print("======== BeamCtr ADD ", "type:", type(of: p.1), "midi", p.0.midiNumber, "\tseq:", p.0.sequence, "\tBeam:", p.0.beamType) //+ "\tOrigin:", p.1.origin)
        DispatchQueue.main.async {
            self.updated += 1
        }
    }
    
    func getNotes() -> [(Note, Note, CGRect, CGRect)] {
        var result:[(Note, Note, CGRect, CGRect)] = []
        self.notePositions = notePositions.sorted(by: { $0.0.sequence < $1.0.sequence })
        if notePositions.count > 1 {
            for i in 0..<notePositions.count-1 {
                //print("==== BeamCtr GET notes\t", notes[i].0.beamType, notes[i].0.midiNumber, "\tX:", notes[i].1.origin.x)
                result.append((notePositions[i].0, notePositions[i+1].0, notePositions[i].1, notePositions[i+1].1))
            }
        }
        
        if result.count > 0 {
            BeamCounter.lastNonZeroPostions = result.map { $0 }
            //print("====Beam Ctr", result.count)
            return result
        }
        else {
            //print("====Beam Ctr NONE", BeamCounter.lastNonZeroPostions.count)
            return BeamCounter.lastNonZeroPostions
        }
        //return result
    }
}

struct QuaverBeamView: View {
    @ObservedObject var beamCounter:BeamCounter
    var staff:Staff
    var lineSpacing:Int
    var noteWidth:Double
    
    init(beamCounter:BeamCounter, staff:Staff, lineSpacing:Int, noteWidth:Double) {
        self.beamCounter = beamCounter
        self.staff = staff
        self.lineSpacing = lineSpacing
        self.noteWidth = noteWidth
        //print ("======== QuaverBeamView init", beamCounter.notes.count)
    }
    
    var body: some View {
        VStack {
            //ForEach<Array<(Note, Note, CGRect, CGRect)>, UUID, Optional<_ShapeView<_StrokedShape<Path>, Color>>>: the ID 21A7FFA1-4961-453A-9C85-F7322053BFF8 occurs multiple times within the collection, this will give undefined results!
            GeometryReader { geo in
                ForEach(beamCounter.getNotes(), id: \.0.id) { note1, note2, rect1, rect2 in
                    if note1.beamType == .start && note2.beamType == .end {
                        let stemDirection:Double = (note1.midiNumber < 71 || note1.isOnlyRhythmNote)  ? -1 : 1
                        
                        let offsetFromStaffMiddle1:Double = Double(staff.getNoteViewData(noteValue: note1.midiNumber).0)
                        let offsetFromStaffMiddle2:Double = Double(staff.getNoteViewData(noteValue: note2.midiNumber).0) 
                        
                        let y1:Double = rect1.midY - (offsetFromStaffMiddle1 * Double(lineSpacing)) / 2.0 + (note1.stemLength * Double(lineSpacing)) * stemDirection
                        let y2:Double = rect2.midY - (offsetFromStaffMiddle2 * Double(lineSpacing)) / 2.0 + (note2.stemLength * Double(lineSpacing)) * stemDirection
                        
                        let x1:Double = rect1.midX - noteWidth / 2.0 * stemDirection
                        let x2:Double = rect2.midX - noteWidth / 2.0 * stemDirection

                        Path { path in
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }
                        //.clipped()
                        //print("  ==>QuaverBeamView  \tmidis", note1.midiNumber, note2.midiNumber, "\tBeam", note1.beamType, note2.beamType) //, rect1.origin, rect1.minX)
                        .stroke(Color.black, lineWidth: 3)
                    }
                 }
            }
        }
        //.onAppear(BeamCounter.lastNonZeroPostions = [])
    }
}

struct StaffLinesView: View {
    @ObservedObject var staff:Staff
    var lineSpacing:Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if staff.linesInStaff > 1 {
                    ForEach(-2..<3) { row in
                        Path { path in
                            let y:Double = (geometry.size.height / 2.0) + Double(row * lineSpacing)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                        //.fill(Color(.black))
                        .stroke(Color.black, lineWidth: 1)
                    }
                }
                else {
                    Path { path in
                        let y:Double = geometry.size.height/2.0
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
                
                // end of staff bar lines
                Path { path in
                    //let y:Double = Double(geometry.size.height) / 2.0
                    let x:Double = geometry.size.width - 2.0
                    let top:Double = (geometry.size.height/2.0) + Double(2 * lineSpacing)
                    let bottom:Double = (geometry.size.height/2.0) - Double(2 * lineSpacing)
                    path.move(to: CGPoint(x: x, y: top))
                    path.addLine(to: CGPoint(x: x, y: bottom))
                }
                .stroke(Color.black, lineWidth: Double(lineSpacing) / 3)
            }
        }
    }
}

struct TimeSignatureView: View {
    @ObservedObject var staff:Staff
    //var parentGeometry: GeometryProxy
    var lineSpacing:Int
    var clefWidth:Double
    
    func calculateFontSize(for size: CGSize) -> CGFloat {
        let width = size.width
        let height = size.height
        
        // Calculate font size based on your desired logic
        let fontSize = min(width, height) * 0.2 // Adjust the multiplier to fit your needs
        
        return fontSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                //Need to squash numerator and denominator of time sig together to overidde default spacing of the text fields
                //TODO same as above - too large of a font size screws al algnemnt of everythgn
                let timeSignatureFontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.5)
                //let timeSignatureFontSize:Double = calculateFontSize(for: geometry.size)

                let squash:CGFloat = CGFloat(lineSpacing)/2.5
                Spacer()
                Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: squash)
                //padding required since these text fields down line up on the staff center line. So padding her to push entire time sig up
                //Text("4").padding(.bottom, 1 * CGFloat(lineSpacing)).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                Spacer()
            }
            .bold()
            .frame(width: clefWidth)
        }
    }
}

struct CustomCGPoint: Equatable {
    var x: CGFloat
    var y: CGFloat
    
    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct MyView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
    }
}

struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff

    var lineSpacing:Int
    var beamCounter:BeamCounter = BeamCounter()
    @State private var rotationId: UUID = UUID()
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var position: CGPoint = .zero

    init (score:Score, staff:Staff, lineSpacing:Int) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
    }
    
    func clefWidth() -> Double {
        return Double(lineSpacing) * 3.0
    }
    
    func getNotes(entry:ScoreEntry) -> [Note] {
        if entry is TimeSlice {
            let ts = entry as! TimeSlice
            return ts.notes
        }
        else {
            let n:[Note] = []
            return n
        }
    }
    
    var body: some View {
        ZStack (alignment: .leading) {
            
            StaffLinesView(staff: staff, lineSpacing: lineSpacing)
            
            HStack {
                if staff.linesInStaff != 1 {
                    HStack {
                        if staff.type == StaffType.treble {
                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 10)))
                        }
                        else {
                            Text("\u{1d122}").font(.system(size: CGFloat(Double(lineSpacing) * 5.5)))
                        }
                    }
                    .padding(.bottom, staff.type == .treble ? Double(lineSpacing) * 1.3 : Double(lineSpacing) * 0.8)
                    .frame(width: clefWidth())
                    //.border(Color.green)
                }
                
                TimeSignatureView(staff: staff, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0).padding(.leading, -10)
                
                ForEach(score.scoreEntries, id: \.self) { entry in
                    ZStack {
                        if entry is TimeSlice {
                            ForEach(getNotes(entry: entry), id: \.self) { note in
                                VStack {
                                    GeometryReader { geoforNote in
                                        if note.staff == nil || note.staff == staff.staffNum {
                                            NoteView(staff: staff,
                                                     note: note,
                                                     noteWidth: Double(lineSpacing) * 1.2,
                                                     lineSpacing: lineSpacing)
                                            //only called when view first apepars, e.g. not when device rotated
                                            .onAppear {
                                                let position = geoforNote.frame(in: .named("Staff1"))
                                                beamCounter.add(p: (note, position))
                                            }
                                        }
                                    }
                                }
                            }
                            if let tag = (entry as! TimeSlice).tag {
                                if staff.staffNum == 0 {
                                    VStack {
                                        Spacer()
                                        Text(tag)
                                            //.fontDesign(.serif)
                                            .font(.custom("Times New Roman", size: Double(lineSpacing) * 2.0)).bold()//.foregroundColor(.blue).padding()
                                    }
                                }
                            }
                        }
                    }

                    if entry is BarLine {
                        BarLineView(entry:entry, staff: staff, lineSpacing: lineSpacing)
                    }
                }
                //.coordinateSpace(name: "Staff0")
            }
            .coordinateSpace(name: "Staff1")
            if staff.type == .treble {
                QuaverBeamView(beamCounter: self.beamCounter, staff:staff, lineSpacing:lineSpacing, noteWidth: Double(lineSpacing) * 1.2) //at left edge
                //                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                //                    //self.beamCounter.notePositions = []
                //                    rotationId = UUID() // Update the ID when device rotation occurs
                //                    print("============================= ROTATION OCCURRED")
                //                    beamCounter.rotationOccured = true
                //                }
            }
            //.coordinateSpace(name: "Staff2")
        }
        //.coordinateSpace(name: "Staff3")
        //.border(Color.orange)
    }
        
}

//                                            .onChange(of: rotationId) { _ in
//                                                let position = geo.frame(in: .named("Staff1"))
//                                                beamCounter.add(p: (note, position))
//                                            }
//.position(position)
//                                            .onAppear {
//                                                //position = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)
//                                                let pos = geo.frame(in: .named("Staff1"))
//                                                beamCounter.add(p: (note, pos))
//                                            }
//                                            .onChange(of: verticalSizeClass) { _ in
//                                                //position = CGPoint(x: geometry.frame(in: .global).midX, y: geometry.frame(in: .global).midY)
//                                                let pos = geo.frame(in: .named("Staff1"))
//                                                beamCounter.add(p: (note, pos))
//                                            }

//.border(Color.blue)
//    var body1: some View {
//        //GeometryReader { geo in
//            ZStack (alignment: .leading) {
//
//               // StaffLinesView(staff: staff, parentGeometry: geo, lineSpacing: lineSpacing)
//                //Text("---------------- STAFF VIEW IS ORANGE ---------------")
//                StaffLinesView(staff: staff, lineSpacing: lineSpacing)
//
//                HStack {
//                    if staff.linesInStaff != 1 {
//                        HStack {
//                            if staff.type == StaffType.treble {
//                                Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 10)))
//                            }
//                            else {
//                                Text("\u{1d122}").font(.system(size: CGFloat(Double(lineSpacing) * 5.5)))
//                            }
//                        }
//                        .padding(.bottom, staff.type == .treble ? Double(lineSpacing) * 1.3 : Double(lineSpacing) * 0.8)
//                        .frame(width: clefWidth())
//                        .border(Color.green)
//                    }
//                    TimeSignatureView(staff: staff, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0).padding(.leading, -10)
//                }
//            }
//        //}
//        .border(Color.orange)
//    }
        
  
