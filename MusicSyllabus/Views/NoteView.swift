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
    @ObservedObject var note:Note
    var staff:Staff
    var color: Color
    var lineSpacing:Int
    var noteWidth:Double
    var offsetFromStaffMiddle:Int
    var accidental:String
    var ledgerLines:[Int]
    
    init(staff:Staff, note:Note, noteWidth:Double, lineSpacing: Int) {
        self.staff = staff
        self.note = note
        self.noteWidth = noteWidth
        self.color = Color.black //Color.blue
        self.lineSpacing = lineSpacing
        let pos = staff.getNoteViewData(noteValue: note.midiNumber)
        offsetFromStaffMiddle = pos.0
        accidental = pos.1
        ledgerLines = pos.2
    }
            
    var body: some View {
        GeometryReader { geometry in
            let noteEllipseMidpoint:Double = geometry.size.height/2.0 - Double(offsetFromStaffMiddle * lineSpacing) / 2.0
            let stemDirection:Double = note.midiNumber <= 71 ? -1 : 1

            ZStack {
                if [Note.VALUE_QUARTER, Note.VALUE_QUAVER].contains(note.value)  {
                    Ellipse()
                        //Closed ellipse
                        //.stroke(Color.black, lineWidth: note.value == 4 ? 0 : 2) // minim or use foreground color for 1/4 note
                        .foregroundColor(self.color)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                        .position(x: geometry.size.width/2, y: noteEllipseMidpoint)
                }
                if note.value == Note.VALUE_HALF || note.value == Note.VALUE_WHOLE {
                    Ellipse()
                        //Open ellipse
                        .stroke(Color.black, lineWidth: 2)
                        //.foregroundColor(note.value == 4 ? self.color : .blue)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 0.9))
                        .position(x: geometry.size.width/2, y: noteEllipseMidpoint)
                }
                
                // stem
                if note.value != Note.VALUE_WHOLE {
                    //Note this code eventually has to go to the code that draws quaver beams since a quaver beam can shorten/lengthen the note stem
                    let xOffset:Double = 1.0 * stemDirection
                    let yOffset:Double = 1.0 * stemDirection
                    Path { path in
                        path.move(to: CGPoint(x: (geometry.size.width - (noteWidth * xOffset))/2.0,
                                              y: noteEllipseMidpoint))
                        path.addLine(to: CGPoint(x: (geometry.size.width - (noteWidth * xOffset))/2.0,
                                                 y: noteEllipseMidpoint + (note.stemLength * Double(lineSpacing) * yOffset)))
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
                
                // quaver beam
//                if note.beamType != .none {
//                    let xOffset:Double = -1.0 * stemDirection
//                    if note.beamType == .start {
//                        Path { path in
//                            path.move(to: CGPoint(x: (geometry.size.width + (noteWidth * xOffset))/2.0,
//                                                  y: Double(noteEllipseMidpoint)+(note.stemLength * Double(lineSpacing))))
//                            path.addLine(to: CGPoint(x: geometry.size.width,
//                                                     y: Double(noteEllipseMidpoint)+(note.stemLength * Double(lineSpacing))))
//                        }
//                        .stroke(Color.black, lineWidth: 1)
//                    }
//                    else {
//                        Path { path in
//                            path.move(to: CGPoint(x: (geometry.size.width + (noteWidth * xOffset))/2.0,
//                                                  y: Double(noteEllipseMidpoint)+(note.stemLength * Double(lineSpacing))))
//                            path.addLine(to: CGPoint(x: 0,
//                                                     y: Double(noteEllipseMidpoint)+(note.stemLength * Double(lineSpacing))))
//                        }
//                        .stroke(Color.black, lineWidth: 1)
//
//                    }
//                }
                
                // hilite
                if note.hilite {
                    Ellipse()
                        .stroke(Color.blue, lineWidth: 3) // minim or use foreground color for 1/4 note
                        .frame(width: noteWidth * 1.8, height: CGFloat(Double(lineSpacing) * 1.8))
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        //.opacity(Double(opacity))
                }
            }
            //.border(Color.green)
        }
    }
}
