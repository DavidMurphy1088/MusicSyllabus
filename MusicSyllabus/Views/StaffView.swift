import SwiftUI
import CoreData
import MessageUI

class BeamCounter : ObservableObject  {
    static let shared = BeamCounter()
    var notes:[(Note, CGRect)] = []
    @Published var updated:Int = 0
    
    init() {
    }
    
    func add(p: (Note, CGRect)) {
        self.notes.append(p)
        print("======== BeamCtr ADD ", "type:", type(of: p.1), "midi", p.0.midiNumber, "\tOrigin:", p.1.origin)
        DispatchQueue.main.async {
            self.updated += 1
        }
    }
    func getNotes() -> [(Note, Note, CGRect, CGRect)] {
        var result:[(Note, Note, CGRect, CGRect)] = []
        if notes.count > 1 {
            for i in 0..<notes.count-1 {
                print("==== BeamCtr GET notes\t", notes[i].0.beamType, notes[i].0.midiNumber, "\tX:", notes[i].1.origin.x)
                result.append((notes[i].0, notes[i+1].0, notes[i].1, notes[i+1].1))
            }
        }
        return result
    }
}

struct QuaverBeamView: View {
    @ObservedObject var beamCounter:BeamCounter
    init(beamCounter:BeamCounter) {
        self.beamCounter = beamCounter
        //print ("======== BeamCtr View init", beamCounter.notes.count)
    }
    var body: some View {
        VStack {
            GeometryReader { geo in
//                Path { path in
//                    path.move(to: CGPoint(x: 0, y: 0))
//                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
//                    //print("+++++++++++", rect)
//                }
//                //.stroke(Color.black, lineWidth: 1)
                ForEach(beamCounter.getNotes(), id: \.0.id) { note1, note2, rect1, rect2 in
                    Path { path in
                        //path.move(to: CGPoint(x: 0, y: 0))
                        path.move(to: CGPoint(x: rect1.midX, y: rect1.midY))
                        path.addLine(to: CGPoint(x: rect2.midX, y: rect2.midY))
                        //print("      +++++++++++", rect.origin, rect.minX)
                    }
                    .stroke(Color.red, lineWidth: 3 )
                }
            }
        }
    }
}

struct QuaverBeamView1: View {
    var staff:Staff
    var note:Note
    var noteWidth: Double
    var stemDirection: Int
    var stemHeight:Double
    var offsetFromStaffMiddle:Double
    var lineSpacing:Double
    let beamCounter:BeamCounter = BeamCounter.shared
    
    init(staff:Staff, noteWidth:Double, stemDirection:Int, stemHeight:Double, lineSpacing: Double) {
        self.note = Note(num: 72)
        self.staff = staff
        //self.note = note
        self.noteWidth = noteWidth
        self.stemDirection = stemDirection
        self.stemHeight = stemHeight
        let pos = staff.getNoteViewData(noteValue: note.midiNumber)
        self.stemDirection = stemDirection
        self.stemHeight = stemHeight
        self.lineSpacing = lineSpacing
        offsetFromStaffMiddle = Double(pos.0)
        offsetFromStaffMiddle = (offsetFromStaffMiddle * lineSpacing/2.0)// + self.stemHeight
        //beamCounter.addNote(note: self.note)
    }
    
//    init(beamNotes: [Int: (Note, CGRect)]) {
//        ForEach(beamNotes.keys.sorted(), id: \.self) { key in
//        }
//
//    }
    
    var body: some View {
        GeometryReader { geometry in
            if note.value == Note.VALUE_QUAVER {
                if note.beamType == .end {
                    let ellipseYMidpoint = geometry.size.height/2.0 - offsetFromStaffMiddle + stemHeight - lineSpacing
                    VStack {
                        Text("\(note.midiNumber)")
                        Text(note.value == Note.VALUE_QUAVER ? "Q" : "")
//                        Path { path in
//                            let mid = geometry.size.width/2.0 - noteWidth / 2.0
//                            let y = ellipseYMidpoint
//                            path.move(to: CGPoint(x: mid, y:y))
//                            path.addLine(to: CGPoint(x: mid + 20.0, y:y - 20.0))
//                        }
//                        .stroke(Color.black, lineWidth: 1)
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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                //Need to squash numerator and denominator of time sig together to overidde default spacing of the text fields
                //TODO same as above - too large of a font size screws al algnemnt of everythgn
                let timeSignatureFontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.5)
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
    //@State private var beamNotes: [Int: (Note, CGRect)] = [:]

    var lineSpacing:Int
    var beamCounter:BeamCounter = BeamCounter.shared

    init (score:Score, staff:Staff, lineSpacing:Int) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
    }
    
    func clefWidth() -> Double {
        return Double(lineSpacing) * 3.5
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
                //let stemHeight = Double(lineSpacing) * 1.2 * 2.5
                StaffLinesView(staff: staff, parentGeometry: geo, lineSpacing: lineSpacing)
                HStack { //GeometryReader { geo11 in
                    HStack {
                        if staff.type == StaffType.treble {
                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 9)))
                        }
                        else {
                            Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                        }
                    }
                    .frame(width: clefWidth())
                    //.border(Color.green)
                    TimeSignatureView(staff: staff, parentGeometry: geo, lineSpacing: lineSpacing, clefWidth: clefWidth())
                    ForEach(score.scoreEntries, id: \.self) { entry in
                        ZStack {
                            if entry is TimeSlice {
                                //let note = getNotes(entry: entry)[0]
                                ForEach(getNotes(entry: entry), id: \.self) { note in
                                    VStack {
                                        GeometryReader { geo in
                                        NoteView(staff: staff,
                                                 note: note,
                                                 noteWidth: Double(lineSpacing) * 1.2,
                                                 lineSpacing: lineSpacing)
                                        .onAppear {
                                            let position = geo.frame(in: .named("Staff1"))
                                            //let position = geo.frame(in: .global)//
                                            //print("-->Text position in parent: \(ctr)    \(position.origin)", score.scoreEntries.count)
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
                QuaverBeamView(beamCounter: self.beamCounter) //at left edge

                }
            .coordinateSpace(name: "Staff2")
            }
        .coordinateSpace(name: "Staff3")

        //.border(.red)
        

    }
}

//extension CGRect {
//    func origin(for index: Int) -> CGPoint {
//        return CGPoint(x: self.minX, y: self.minY + (CGFloat(index) * 20))
//    }
//}
