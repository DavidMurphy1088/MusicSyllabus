import SwiftUI
import CoreData
import MessageUI

struct BarLineView: View {
    var entry:ScoreEntry
    var staff:Staff
    var lineSpacing:Double

    var body: some View {
//        VStack {
//            Text("B")
//        }
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.black)
                .frame(width: 1.0, height: 4.0 * Double(lineSpacing))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .border(Color.green)
        }
        .frame(maxWidth: Double(lineSpacing)  * 1.0)
        //.border(Color.red)
    }
}

struct NoteView: View {
    @ObservedObject var note:Note
    var staff:Staff
    var color: Color
    var lineSpacing:Double
    var noteWidth:Double
    var offsetFromStaffMiddle:Int
    
    init(staff:Staff, note:Note, noteWidth:Double, lineSpacing: Double, offsetFromStaffMiddle:Int) {
        self.staff = staff
        self.note = note
        self.noteWidth = noteWidth
        self.color = Color.black //Color.blue
        self.lineSpacing = lineSpacing
        self.offsetFromStaffMiddle = offsetFromStaffMiddle
    }
            
    var body: some View {
        GeometryReader { geometry in
            let noteFrameWidth = geometry.size.width * 1.0 //center the note in the space allocated by the parent for this note's view
            let noteEllipseMidpoint:Double = geometry.size.height/2.0 - Double(offsetFromStaffMiddle) * lineSpacing / 2.0
            let noteColor = note.noteTag == .inError ? Color(.red) : Color(.black)
            let noteValueUnDotted = note.isDotted ? note.value * 2.0/3.0 : note.value
            //let noteLayout = staff.notePositions.getLayout(note: note)
//            let xDirection:Double = -1.0 * Double(noteLayout.stemDirection)
//            let yDirection:Double = -1.0 * Double(noteLayout.stemDirection)

            ZStack {
                //Note ellipse
                if [Note.VALUE_QUARTER, Note.VALUE_QUAVER].contains(noteValueUnDotted )  {
                    Ellipse()
                        //Closed ellipse
                        //.stroke(Color.black, lineWidth: note.value == 4 ? 0 : 2) // minim or use foreground color for 1/4 note
                        .foregroundColor(noteColor)
                        .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 1.0))
                        .position(x: noteFrameWidth/2, y: noteEllipseMidpoint)
                        //.foregroundColor(noteColor)
                }
                if noteValueUnDotted  == Note.VALUE_HALF || noteValueUnDotted == Note.VALUE_WHOLE {
                        Ellipse()
                        //Open ellipse
                            .stroke(noteColor, lineWidth: 2)
                            .frame(width: noteWidth, height: CGFloat(Double(lineSpacing) * 0.9))
                            .position(x: noteFrameWidth/2, y: noteEllipseMidpoint)
                            //.frame(width:6) //trying to have minim have more horz space
                }
                                                
                //dotted
                if note.isDotted {
                    Ellipse()
                        //Open ellipse
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: noteWidth/4.0, height: noteWidth/4.0)
                        .position(x: noteFrameWidth/2 + noteWidth/1.0, y: noteEllipseMidpoint)
                        .foregroundColor(noteColor)
                        //.border(Color .red)
                }

                 //ledger line hack - totally not generalized :(
                if staff.type == .treble {
                    if note.midiNumber <= Note.MIDDLE_C {
                        let xOffset:Double = UIDevice.current.userInterfaceIdiom == .phone ? -Double(lineSpacing) / 2.0 : 0
                        Path { path in
                            path.move(to: CGPoint(x: (xOffset), y: noteEllipseMidpoint))
                            path.addLine(to: CGPoint(x: (noteFrameWidth - xOffset), y: noteEllipseMidpoint))
                        }
                        .stroke(Color.black, lineWidth: 1)
                    }
                }
                
                // hilite
                if note.hilite {
                    Ellipse()
                        .stroke(Color.blue, lineWidth: 3) // minim or use foreground color for 1/4 note
                        .frame(width: noteWidth * 1.8, height: CGFloat(Double(lineSpacing) * 1.8))
                        .position(x: noteFrameWidth/2, y: CGFloat(noteEllipseMidpoint))
                        //.opacity(Double(opacity))
                }
            }
            //.border(Color.green)
        }
    }
}
