import SwiftUI
import CoreData
import MessageUI

struct StaffLinesView: View {
    @ObservedObject var staff:Staff
    var lineSpacing:Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if staff.linesInStaff > 1 {
                    ForEach(-2..<3) { row in
                        Path { path in
                            let y:Double = (geometry.size.height / 2.0) + Double(row) * lineSpacing
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
    var lineSpacing:Double
    var clefWidth:Double
    
    var body: some View {
        let timeSignatureFontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.2)
        let padding:Double = Double(lineSpacing) / 3.0
        
        if timeSignature.isCommonTime {
            Text(" C")
                .font(.custom("Times New Roman", size: timeSignatureFontSize * 1.1)).bold()
        }
        else {
            VStack (spacing: 0) {
                Text(" \(timeSignature.top)").font(.system(size: timeSignatureFontSize)).padding(.vertical, -padding)
                Text(" \(timeSignature.bottom)").font(.system(size: timeSignatureFontSize)).padding(.vertical, -padding)
            }
        }
    }
}

struct CleffView: View {
    @ObservedObject var staff:Staff
    var lineSpacing:Double

    var body: some View {
        HStack {
            if staff.type == StaffType.treble {
                Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 10)))
            }
            else {
                Text("\u{1d122}").font(.system(size: CGFloat(Double(lineSpacing) * 5.5)))
            }
        }
    }
}

struct KeySignatureView: View {
    @ObservedObject var score:Score
    var lineSpacing:Double

    var body: some View {
        //if score.key.keySig.accidentalCount > 0 {
        GeometryReader { geometry in
            VStack {
                let noteEllipseMidpoint:Double = geometry.size.height/2.0 - Double(4 * lineSpacing) / 2.0
                Text("#").font(.system(size: Double(lineSpacing) * 2.3)).bold()
                    .position(CGPoint(x: geometry.size.width/2.0, y: noteEllipseMidpoint))
            }
            //.border(Color.blue)
        }
        .frame(width: lineSpacing * 1.5)
    }
}

struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff
    //@ObservedObject var noteLayoutPositions:NoteLayoutPositions

    var lineSpacing:Double
    @State private var rotationId: UUID = UUID()
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var position: CGPoint = .zero
    var entryPositions:[Double] = []
    var totalDuration = 0.0

    init (score:Score, staff:Staff, lineSpacing:Double) {
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
    
    func xPos(note:Note) -> CGFloat {
        return CGFloat(self.entryPositions[note.sequence])
    }
    
    var body: some View {
        ZStack { // The staff lines view and everything else on the staff share the same space
            StaffLinesView(staff: staff, lineSpacing: lineSpacing)
            
            HStack(spacing: 0) {
                if staff.linesInStaff != 1 {
                    CleffView(staff: staff, lineSpacing: lineSpacing)
                    KeySignatureView(score: score, lineSpacing: lineSpacing)
                }
                
                TimeSignatureView(staff: staff, timeSignature: score.timeSignature, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0)
                //    .border(Color.red)

                StaffNotesView(score: score, staff: staff, lineSpacing: lineSpacing)
                Text("      ")
            }
        }
    }
    
//    var body1: some View {
//        GeometryReader { geometry in
//        ZStack (alignment: .leading) { // The staff lines view and everything else on the staff share the same space
//            
//            StaffLinesView(staff: staff, lineSpacing: lineSpacing)
//
//            HStack(spacing: 0) {
//                //clefs
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
//                        //.border(Color.green)
//
//                        //Key signature
//                        if score.key.keySig.accidentalCount > 0 {
//                            GeometryReader { geometry in
//                                let noteEllipseMidpoint:Double = geometry.size.height/2.0 - Double(4 * lineSpacing) / 2.0
//                                Text("#").font(.system(size: Double(lineSpacing) * 2.3)).bold()
//                                    .position(CGPoint(x: geometry.size.width/2.0, y: noteEllipseMidpoint))
//                                //.border(Color.blue)
//                            }
//                        }
//                    }
//                }
//                
//                TimeSignatureView(staff: staff, timeSignature: score.timeSignature, lineSpacing: lineSpacing, clefWidth: clefWidth()/1.0)
//                  //.border(Color.red)
//
//                ZStack { // The sequence of notes view and the stem drawing view share the same space
//                    let frameWidth = (geometry.size.width * 0.75) / Double(score.scoreEntries.count)
//                    
//                    HStack(spacing: 0) { // Each timeslice entry lays out in an HStack, spacing:0 ensures no space between the note view frames
//                        ForEach(score.scoreEntries, id: \.self) { entry in
//                            if entry is TimeSlice {
//                                ZStack { // Each note frame in the timeslice shares the same same space
//                                    ForEach(getNotes(entry: entry), id: \.self) { note in
//                                        //VStack {
//                                            //GeometryReader { geoforNote in
//                                                if note.staff == nil || note.staff == staff.staffNum {
//                                                    NoteView(staff: staff,
//                                                             note: note,
//                                                             noteWidth: Double(lineSpacing) * 1.2,
//                                                             lineSpacing: lineSpacing)
//                                                }
//                                            //}
//                                            //.padding(.all, 0)
//                                        //}
//                                    }
//                                    if let tag = (entry as! TimeSlice).tag {
//                                        if staff.staffNum == 0 {
//                                            VStack {
//                                                Spacer()
//                                                Text(tag)
//                                                //.fontDesign(.serif)
//                                                    .font(.custom("Times New Roman", size: Double(lineSpacing) * 2.0)).bold()//.foregroundColor(.blue).padding()
//                                            }
//                                        }
//                                    }
//                                }
//                                .border(Color.green)
//                            }
//
//                            if entry is BarLine {
//                                BarLineView(entry:entry, staff: staff, lineSpacing: lineSpacing)
//                                //.border(Color.red)
//                            }
//                        }
//                        .frame(width: frameWidth) //, height: 150)
//                        .padding(.all, 0)
//                        .border(Color.green)
//                    }
//                    
//                    NoteStemsView(score: score, frameWidth: frameWidth)
//                }
//                
//                //Space between last time slice and the end of the staff
//                VStack {
//                    Text("e ")
//                }
//                //.frame(width: Double(lineSpacing) * 1.0)
//                //.border(Color.red)
//            }
//            .coordinateSpace(name: "Staff1")
//        }
//        //.coordinateSpace(name: "Staff3")
//        //.border(Color.orange)
//        }
//    }
        
}

