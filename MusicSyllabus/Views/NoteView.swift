import SwiftUI
import CoreData
import MessageUI

struct BarLineView: View {
    var staff:Staff
    var lineSpacing:Int
    
    var body: some View {
        GeometryReader { geometry in
            //Text("b")
            Path { path in
                //let y = midPoint
                path.move(to: CGPoint(x: Int(geometry.size.width)/2, y: Int(geometry.size.height)/2 + 2 * lineSpacing))
                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2, y: Int(geometry.size.height)/2 - 2 * lineSpacing))
            }
            .stroke(Color.black, lineWidth: 1)
            .border(Color.green)
        }
    }
}
struct NoteView: View {
    var staff:Staff
    var note:Note
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
//                    Text(accidental)
//                        .frame(width: CGFloat(ledgerLineWidth) * 3.5, alignment: .leading)
//                        //.border(Color.green) //DEBUG ONLY - not pos of .border in properties matters - different if after .position
//                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffMiddle! * lineSpacing/2))
                
                //self.getNodeBody(geometry: geometry, noteEllipseMidpoint: noteEllipseMidpoint)
                if note.value == 4 {
                    Ellipse()
                        //.stroke(Color.black, lineWidth: note.value == 4 ? 0 : 2) // minim or use foreground color for 1/4 note
                        .foregroundColor(self.color)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0)) 
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        .opacity(Double(opacity))
                }
                else {
                    Ellipse()
                        .stroke(Color.black, lineWidth: note.value == 4 ? 0 : 2) // minim or use foreground color for 1/4 note
                        //.foregroundColor(note.value == 4 ? self.color : .blue)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 0.9))
                        .position(x: geometry.size.width/2, y: CGFloat(noteEllipseMidpoint))
                        .opacity(Double(opacity))
                }
                
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

//                    if ledgerLines.count > 0 {
//                        ForEach(0..<ledgerLines.count) { row in
//                            Path { path in
//                                path.move(to: CGPoint(x: Int(geometry.size.width)/2 - ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
//                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 + ledgerLineWidth+1, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2))
//                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 + ledgerLineWidth+1, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
//                                path.addLine(to: CGPoint(x: Int(geometry.size.width)/2 - ledgerLineWidth, y: (offsetFromStaffTop! + ledgerLines[row]) * lineSpacing/2 + StaffView.lineHeight))
//                                path.closeSubpath()
//                            }
//                            .fill(self.color)
//                            //.opacity(Double(opacity))
//                        }
//                    }
            }
            //.border(Color.green)
        }
    }
}

