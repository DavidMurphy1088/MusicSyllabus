import SwiftUI
import CoreData
import MessageUI

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
    let ledgerLineWidth:Int
    
    init(staff:Staff, note:Note, stemDirection:Int, lineSpacing: Int, opacity:Int) {
        self.staff = staff
        self.note = note
        self.color = Color.black //Color.blue
        self.lineSpacing = lineSpacing
        self.opacity = opacity
        let pos = staff.getNoteViewData(noteValue: note.num)
        self.stemDirection = stemDirection
        offsetFromStaffMiddle = pos.0
        accidental = pos.1
        ledgerLines = pos.2
        noteWidth = CGFloat(lineSpacing) * 1.2
        ledgerLineWidth = Int(noteWidth * 0.8)
    }
            
    var body: some View {
        GeometryReader { geometry in
            let y = Int(geometry.size.height)/2 - offsetFromStaffMiddle * lineSpacing/2
            ZStack {
//                    Text(accidental)
//                        .frame(width: CGFloat(ledgerLineWidth) * 3.5, alignment: .leading)
//                        //.border(Color.green) //DEBUG ONLY - not pos of .border in properties matters - different if after .position
//                        .position(x: geometry.size.width/2, y: CGFloat(offsetFromStaffMiddle! * lineSpacing/2))
                Ellipse()
                //Text("X")
                    //.stroke(Color.black, lineWidth: 2) // minim or use foreground color for 1/4 note
                    .foregroundColor(self.color)
                    //the note ellipses line up in the center of the view
                    .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                    //.border(self.staff.staffNum == 0 ? Color.red : Color.green)
                    
                    .position(x: geometry.size.width/2, y: CGFloat(y))
                    .opacity(Double(opacity))
                    
                
                Path { path in
                    let h:CGFloat = 32
                    let dlta:CGFloat = 5
                    if stemDirection == 0 {
                        path.move(to: CGPoint(x: geometry.size.width-dlta, y: CGFloat(y)-dlta/2))
                        path.addLine(to: CGPoint(x: geometry.size.width-dlta, y: CGFloat(y)-h))
                    }
                    else {
                        path.move(to: CGPoint(x: dlta, y: CGFloat(y) + dlta/2))
                        path.addLine(to: CGPoint(x: dlta, y: CGFloat(y)+h))
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

