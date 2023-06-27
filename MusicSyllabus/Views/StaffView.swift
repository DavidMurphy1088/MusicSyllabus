import SwiftUI
import CoreData
import MessageUI

struct StaffLinesView: View {
    @ObservedObject var staff:Staff
    var lineSpacing:LineSpacing

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if staff.linesInStaff > 1 {
                    ForEach(-2..<3) { row in
                        Path { path in
                            let y:Double = (geometry.size.height / 2.0) + Double(row) * lineSpacing.value
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
                
                let x:Double = geometry.size.width - 2.0
                let top:Double = (geometry.size.height/2.0) + Double(2 * lineSpacing.value)
                let bottom:Double = (geometry.size.height/2.0) - Double(2 * lineSpacing.value)
                
                Path { path in
                    path.move(to: CGPoint(x: x, y: top))
                    path.addLine(to: CGPoint(x: x, y: bottom))
                }
                .stroke(Color.black, lineWidth: Double(lineSpacing.value) / 3)
                let x1:Double = geometry.size.width - (Double(lineSpacing.value) * 0.7)
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
    
    func fontSize(for height: CGFloat) -> CGFloat {
        // Calculate the font size based on the desired pixel height
        let desiredPixelHeight: CGFloat = 48.0
        let scaleFactor: CGFloat = 72.0 // 72 points per inch
        let points = (desiredPixelHeight * 72.0) / scaleFactor
        let scalingFactor = height / UIScreen.main.bounds.size.height
        return points * scalingFactor
    }

    var body: some View {
        //GeometryReader { geometry in
            let padding:Double = Double(lineSpacing) / 3.0
            let fontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.2)
            
            if timeSignature.isCommonTime {
                Text(" C")
                    .font(.custom("Times New Roman", size: fontSize * 1.5)).bold()
                //.font(.system(size: fontSize(for: geometry.size.height)))
            }
            else {
                VStack (spacing: 0) {
                    Text(" \(timeSignature.top)").font(.system(size: fontSize * 1.1)).padding(.vertical, -padding)
                    Text(" \(timeSignature.bottom)").font(.system(size: fontSize  * 1.1)).padding(.vertical, -padding)
                }
            }
        //}
    }
}

struct CleffView: View {
    @ObservedObject var staff:Staff
    @ObservedObject var lineSpacing:LineSpacing

    var body: some View {
        HStack {
            if staff.type == StaffType.treble {
                VStack {
                    Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing.value * 10)))
                        .padding(.top, 0.0)
                        .padding(.bottom, lineSpacing.value * 1.0)
                }
                //.border(Color.red)
            }
            else {
                Text("\u{1d122}").font(.system(size: CGFloat(Double(lineSpacing.value) * 5.5)))
            }
        }
        //.border(Color.green)
    }
}

struct KeySignatureView: View {
    @ObservedObject var score:Score
    var lineSpacing:Double
    var staffOffset:Int
    
    var body: some View {
        //if score.key.keySig.accidentalCount > 0 {
        GeometryReader { geometry in
            VStack {
                Image("sharp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: lineSpacing)
                    .position(CGPoint(x: geometry.size.width/2.0, y: geometry.size.height/2.0 - Double(staffOffset) * lineSpacing / 2.0))
            }
            //.border(Color.blue)
        }
        .frame(width: lineSpacing * 1.5)
    }
}

struct StaffView: View {
    let id = UUID()
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff
    @ObservedObject var lineSpacing:LineSpacing
    //@ObservedObject var noteLayoutPositions:NoteLayoutPositions

    @State private var rotationId: UUID = UUID()
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var position: CGPoint = .zero
    var entryPositions:[Double] = []
    var totalDuration = 0.0

    init (score:Score, staff:Staff, lineSpacing:LineSpacing) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
        print("  StaffView init::lineSpace", lineSpacing)
    }
    
    func clefWidth() -> Double {
        return Double(lineSpacing.value) * 3.0
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
    
    func getLineSpacing() -> Double {
        //print("  StaffView body::lineSpace", lineSpacing)
        return lineSpacing.value
    }

    var body: some View {
        ZStack { // The staff lines view and everything else on the staff share the same space
            StaffLinesView(staff: staff, lineSpacing: lineSpacing)
            
            HStack(spacing: 0) {
                if staff.linesInStaff != 1 {
                    CleffView(staff: staff, lineSpacing: lineSpacing)
                    //.border(Color.red)
                    if score.key.keySig.accidentalCount != 0 {
                        KeySignatureView(score: score, lineSpacing: lineSpacing.value, staffOffset: staff.type == .treble ? 4 : 2)
                    }
                }
                    
                TimeSignatureView(staff: staff, timeSignature: score.timeSignature, lineSpacing: lineSpacing.value, clefWidth: clefWidth()/1.0)
                //    .border(Color.red)
                
                StaffNotesView(score: score, staff: staff, lineSpacing: lineSpacing)
                Text("      ")
            }
        }
    }
}

