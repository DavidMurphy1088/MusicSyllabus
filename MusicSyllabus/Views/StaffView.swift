import SwiftUI
import CoreData
import MessageUI

struct QuaverBeamView: View {
    @ObservedObject var beamCounter:StaffQuaverBeamCounter
    var staff:Staff
    var lineSpacing:Int
    var noteWidth:Double
    
    init(beamCounter:StaffQuaverBeamCounter, staff:Staff, lineSpacing:Int, noteWidth:Double) {
        self.beamCounter = beamCounter
        self.staff = staff
        self.lineSpacing = lineSpacing
        self.noteWidth = noteWidth
        //print ("======== QuaverBeamView init", beamCounter.notes.count)
        //print("     ==QuaverBeamView created, staff ID:", staff.id)
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
                
                var x:Double = geometry.size.width - 2.0
                let top:Double = (geometry.size.height/2.0) + Double(2 * lineSpacing)
                let bottom:Double = (geometry.size.height/2.0) - Double(2 * lineSpacing)
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: top))
                    path.addLine(to: CGPoint(x: x, y: bottom))
                }
                .stroke(Color.black, lineWidth: Double(lineSpacing) / 3)
                var x1:Double = geometry.size.width - (Double(lineSpacing) * 0.7)
                Path { path in
                    path.move(to: CGPoint(x: x1, y: top))
                    path.addLine(to: CGPoint(x: x1, y: bottom))
                }
                .stroke(Color.black, lineWidth: 1)
            }
        }
    }
}

struct TimeSignatureView: View {
    @ObservedObject var staff:Staff
    var timeSignature:TimeSignature
    var lineSpacing:Int
    var clefWidth:Double
    
//    func calculateFontSize(for size: CGSize) -> CGFloat {
//        let width = size.width
//        let height = size.height
//
//        // Calculate font size based on your desired logic
//        let fontSize = min(width, height) * 0.2 // Adjust the multiplier to fit your needs
//        return fontSize
//    }
    var body: some View {
        let timeSignatureFontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.2)
        let padding:Double = Double(lineSpacing) / 3.0
        
        if timeSignature.isCommonTime {
            Text("C")
                .font(.custom("Times New Roman", size: timeSignatureFontSize * 1.1)).bold()
        }
        else {
            VStack (spacing: 0) {
                Text("\(timeSignature.top)").font(.system(size: timeSignatureFontSize)).padding(.vertical, -padding)
                Text("\(timeSignature.bottom)").font(.system(size: timeSignatureFontSize)).padding(.vertical, -padding)
            }
        }
    }
}

struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff

    var lineSpacing:Int
    @State private var rotationId: UUID = UUID()
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var position: CGPoint = .zero
    var entryPositions:[Double] = []
    var totalDuration = 0.0

    init (score:Score, staff:Staff, lineSpacing:Int) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
        //print("   ==StaffView created, score ID:", self.score.id)
        
// This code was sritten to be able toposition notes on the staff with spacing between them as a function of their rhythm value
//        for entry in score.scoreEntries {
//            if entry is TimeSlice {
//                //let ts = entry as! TimeSlice
//                let notes = getNotes(entry: entry)
//                if notes.count > 0 {
//                    entryPositions.append(totalDuration)
//                    var value = notes[0].value
//                    if value > 1 {
//                        value = value / 2.0
//                    }
//                    totalDuration += value
//                    print(" tt note,", totalDuration, notes[0].value)
//                }
//            }
//            if entry is BarLine {
//                entryPositions.append(totalDuration)
//                totalDuration += 0.25 //bar line width
//                print(" tt bar ", totalDuration)
//           }
//        }
        //print("StaffView Init", entryPositions.count, entryPositions, "total", totalDuration)
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
    
    func xPos(note:Note) -> CGFloat {
        return CGFloat(self.entryPositions[note.sequence])
    }
    


    var body: some View {
        GeometryReader { geometry in
        ZStack (alignment: .leading) {
            
            StaffLinesView(staff: staff, lineSpacing: lineSpacing)

            HStack {
                //clefs
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
                
                    //Key signature hack
                    if score.key.keySig.accidentalCount > 0 {
                        GeometryReader { geometry in
                            let noteEllipseMidpoint:Double = geometry.size.height/2.0 - Double(4 * lineSpacing) / 2.0
                            Text("#").font(.system(size: Double(lineSpacing) * 2.3)).bold()
                                .position(CGPoint(x: geometry.size.width/2.0, y: noteEllipseMidpoint))
                            //.padding()
                            //.border(Color.blue)
                        }
                    }
                }
                
                TimeSignatureView(staff: staff, timeSignature: score.timeSignature, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0)
                //.border(Color.red)

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
                                            //.frame(width: self.xPos(n: note))
                                            //only called when view first apepars, e.g. not when device rotated
                                            .onAppear {
                                                let position:CGRect = geoforNote.frame(in: .named("Staff1"))
                                                staff.beamCounter.add(p: (note, position))
                                                //let position:CGRect = geoforNote.frame(in: .named("Staff1"))
                                                //print("  staffView", position)
                                            }
                                            //Text("pos:\(String(format: "%.1f", self.notePos[note.sequence]))")
                                            //Text("xpos:\(String(format: "%.1f", geoForNote.x))")
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
                
                //Space between last time slice and the end of the staff
                VStack {
                    Text("")
                }
                .frame(width: Double(lineSpacing) * 1.0)
                //.position(x: geometry.size.width - 50.0, y: geometry.size.height / 2.0)
                //.border(Color.red)
            }
            .coordinateSpace(name: "Staff1")

            if staff.type == .treble {
                QuaverBeamView(beamCounter: staff.beamCounter, staff:staff, lineSpacing:lineSpacing, noteWidth: Double(lineSpacing) * 1.2) //at left edge
            }
            //.coordinateSpace(name: "Staff2")
        }
        //.coordinateSpace(name: "Staff3")
        //.border(Color.orange)
        }
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
        
  
//This version has the view precalc the postions of the notes so it cna place them on the staff with spacing
//as a function of the note's value.
//    var bodyNew: some View {
//        //In SwiftUI, the HStack container view arranges its child views horizontally, and by default, it does not respect the position modifiers applied
//        //to its child views. Instead, it aligns the child views based on their intrinsic content size and alignment settings.
//        GeometryReader { geo in
//            ZStack {
//                StaffLinesView(staff: staff, lineSpacing: lineSpacing)
//
//                //Clef view
//                if staff.linesInStaff != 1 {
//                    HStack {
//                        if staff.type == StaffType.treble {
//                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 10)))
//                        }
//                        else {
//                            Text("\u{1d122}").font(.system(size: CGFloat(Double(lineSpacing) * 5.5)))
//                        }
//                    }
//                    .padding(.bottom, staff.type == .treble ? Double(lineSpacing) * 1.3 : Double(lineSpacing) * 0.8)
//                    .frame(width: clefWidth())
//                    //.border(Color.green)
//                    .position(x: Double(lineSpacing) * 2, y:geo.size.height / 2.0)
//                }
//
//                ForEach(score.scoreEntries, id: \.self) { entry in
//                    if entry is TimeSlice {
//                        ForEach(getNotes(entry: entry), id: \.self) { note in
//                            GeometryReader { geoforNote in
//                                if note.staff == nil || note.staff == staff.staffNum {
//                                    //ZStack {
//                                    //Text("pos:\(String(format: "%.1f", self.notePos[note.sequence]))")
//                                    NoteView(staff: staff,
//                                             note: note, noteWidth: Double(lineSpacing) * 1.0, //1.2
//                                             lineSpacing: lineSpacing)
//                                        //.frame(width: 70)
//                                        .position(x: 100 + CGFloat(entryPositions[entry.sequence]) * geo.size.width/self.totalDuration, y:geo.size.height / 2.0)
//                                    //.position(x: 0)
//                                    //only called when view first apepars, e.g. not when device rotated
//                                    //Text("pos:\(String(format: "%.1f", self.notePos[note.sequence]))")
//                                    //Text("xpos:\(String(format: "%.1f", geoForNote.x))")
//                                        .border(Color.blue)
//                                }
//                                //}
//                            }
//                        }
//                    }
//                    if entry is BarLine {
//                        GeometryReader { geo in
//                            BarLineView(entry:entry, staff: staff, lineSpacing: lineSpacing)
//                                .position(x: 100 + CGFloat(entryPositions[entry.sequence]) * geo.size.width/self.totalDuration, y:geo.size.height / 2.0)
//                                .frame(width: 50)
//                                .border(Color.red)
//                        }
//                    }
//                }
//
//
//            }
//            //.border(Color.red)
//        }
//    }
