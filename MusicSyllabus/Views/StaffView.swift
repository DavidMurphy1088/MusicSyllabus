import SwiftUI
import CoreData
import MessageUI

class BeamCounter : ObservableObject  {
    //static let shared = BeamCounter()
    var notes:[(Note, CGRect)] = []
    @Published var updated:Int = 0
    
    init() {
    }
    
    func add(p: (Note, CGRect)) {
        self.notes.append(p)
        //print("======== BeamCtr ADD ", "type:", type(of: p.1), "midi", p.0.midiNumber, "\tseq:", p.0.sequence, "\tBeam:", p.0.beamType) //+ "\tOrigin:", p.1.origin)
        DispatchQueue.main.async {
            self.updated += 1
        }
    }
    
    func getNotes() -> [(Note, Note, CGRect, CGRect)] {
        var result:[(Note, Note, CGRect, CGRect)] = []
        self.notes = notes.sorted(by: { $0.0.sequence < $1.0.sequence })
        if notes.count > 1 {
            for i in 0..<notes.count-1 {
                //print("==== BeamCtr GET notes\t", notes[i].0.beamType, notes[i].0.midiNumber, "\tX:", notes[i].1.origin.x)
                result.append((notes[i].0, notes[i+1].0, notes[i].1, notes[i+1].1))
            }
        }
        //result = result.sorted(by: { $0.0.sequence < $1.0.sequence })
        return result
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
                        //print("  ==>QuaverBeamView  \tmidis", note1.midiNumber, note2.midiNumber, "\tBeam", note1.beamType, note2.beamType) //, rect1.origin, rect1.minX)
                        .stroke(Color.black, lineWidth: 3)
                    }
                    
                }
            }
        }
    }
}

struct StaffLinesView: View {
    @ObservedObject var staff:Staff
    var parentGeometry: GeometryProxy
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
    var parentGeometry: GeometryProxy
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

struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff

    var lineSpacing:Int
    var beamCounter:BeamCounter = BeamCounter()

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
            return ts.note
        }
        else {
            let n:[Note] = []
            return n
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack (alignment: .leading) {
                
                StaffLinesView(staff: staff, parentGeometry: geo, lineSpacing: lineSpacing)
                
                HStack { //GeometryReader { geo11 in
                    
                    if staff.linesInStaff != 1 {
                        HStack {
                            if staff.type == StaffType.treble {
                                Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 10)))
                            }
                            else {
                                Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                            }
                        }
                        .padding(.bottom, Double(lineSpacing) * 1.3)
                        .frame(width: clefWidth())
                        //.border(Color.green)
                    }
                    
                    TimeSignatureView(staff: staff, parentGeometry: geo, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0).padding(.leading, -10)
                    
                    ForEach(score.scoreEntries, id: \.self) { entry in
                        ZStack {
                            if entry is TimeSlice {
                                ForEach(getNotes(entry: entry), id: \.self) { note in
                                    VStack {
                                        GeometryReader { geo in
                                            NoteView(staff: staff,
                                                 note: note,
                                                 noteWidth: Double(lineSpacing) * 1.2,
                                                 lineSpacing: lineSpacing)
                                            .onAppear {
                                                let position = geo.frame(in: .named("Staff1"))
                                                beamCounter.add(p: (note, position))
                                            }
                                            //.border(Color.blue)
                                        }
                                    }
                                }
                            }
                        }

                        if entry is BarLine {
                            BarLineView(entry:entry, staff: staff, lineSpacing: lineSpacing)
                        }
                    }
                    .coordinateSpace(name: "Staff0")
                }
                .coordinateSpace(name: "Staff1")
                QuaverBeamView(beamCounter: self.beamCounter, staff:staff, lineSpacing:lineSpacing, noteWidth: Double(lineSpacing) * 1.2) //at left edge
            }
            .coordinateSpace(name: "Staff2")
        }
        .coordinateSpace(name: "Staff3")
    }
}

//extension CGRect {
//    func origin(for index: Int) -> CGPoint {
//        return CGPoint(x: self.minX, y: self.minY + (CGFloat(index) * 20))
//    }
//}
