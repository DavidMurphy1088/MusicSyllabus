import SwiftUI
import CoreData
import MessageUI

struct BarLineView: View {
    var entry:ScoreEntry
    var staff:Staff
    var lineSpacing:Int
    
    func xPos(geo: GeometryProxy) -> Int {
        let barLine = entry as! BarLine
        return Int(barLine.atScoreEnd ? geo.size.width - 8 : geo.size.width/2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                //let y = midPoint
                path.move(to: CGPoint(x: xPos(geo: geometry), y: Int(geometry.size.height)/2 + 2 * lineSpacing))
                path.addLine(to: CGPoint(x: xPos(geo: geometry), y: Int(geometry.size.height)/2 - 2 * lineSpacing))
            }
            .stroke(Color.black, lineWidth: 1)
            //.border(Color.green)
        }
    }
}

struct NoteView: View {
    var staff:Staff
    @ObservedObject var note:Note
    var color: Color
    var opacity: Int
    var lineSpacing:Int
    var noteWidth:CGFloat
    var stemDirection: Int
    var offsetFromStaffMiddle:Int
    var accidental:String
    var ledgerLines:[Int]
    
    init(staff:Staff, note:Note, stemDirection:Int, lineSpacing: Int, opacity:Int) {
        self.staff = staff
        self.note = note
        self.color = Color.black //Color.blue
        self.lineSpacing = lineSpacing
        self.opacity = opacity
        let pos = staff.getNoteViewData(noteValue: note.midiNumber)
        self.stemDirection = stemDirection
        offsetFromStaffMiddle = pos.0
        accidental = pos.1
        ledgerLines = pos.2
        noteWidth = CGFloat(lineSpacing) * 1.2
    }
            
    var body: some View {
        GeometryReader { geometry in
            let noteEllipseMidpoint = Int(geometry.size.height)/2 - offsetFromStaffMiddle * lineSpacing/2
            ZStack {
                if note.value == Note.VALUE_QUARTER {
                    Ellipse()
                        //.stroke(Color.black, lineWidth: note.value == 4 ? 0 : 2) // minim or use foreground color for 1/4 note
                        .foregroundColor(self.color)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0)) 
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        .opacity(Double(opacity))
                }
                if note.value == Note.VALUE_HALF || note.value == Note.VALUE_WHOLE {
                    Ellipse()
                        .stroke(Color.black, lineWidth: 2) 
                        //.foregroundColor(note.value == 4 ? self.color : .blue)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 0.9))
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        .opacity(Double(opacity))
                }
                // stem
                if note.value != Note.VALUE_WHOLE {
                    Path { path in
                        let stemHeight:CGFloat = noteWidth * 2.5
                        if stemDirection == 0 || staff.linesInStaff == 1 {
                            path.move(to: CGPoint(x: (geometry.size.width + noteWidth)/2, y: CGFloat(noteEllipseMidpoint)))
                            path.addLine(to: CGPoint(x: (geometry.size.width + noteWidth)/2, y: CGFloat(noteEllipseMidpoint)-stemHeight))
                        }
                        else {
                            path.move(to: CGPoint(x: (geometry.size.width - noteWidth)/2, y: CGFloat(noteEllipseMidpoint)))
                            path.addLine(to: CGPoint(x: (geometry.size.width - noteWidth)/2, y: CGFloat(noteEllipseMidpoint)+stemHeight))
                        }
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
                if note.hilite {
                    Ellipse()
                        .stroke(Color.blue, lineWidth: 3) // minim or use foreground color for 1/4 note
                        .frame(width: noteWidth * 1.8, height: CGFloat(Double(lineSpacing) * 1.8))
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        .opacity(Double(opacity))
                }
            }
            //.border(Color.green)
        }
    }
}

