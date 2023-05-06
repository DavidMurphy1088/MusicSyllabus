import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff
    
    var lineSpacing:Int
    
    init (score:Score, staff:Staff, lineSpacing:Int) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
    }
            
    func colr(line: Int) -> Color {
        if line < score.ledgerLineCount || line >= score.ledgerLineCount + 5 {
            return Color.yellow
        }
        return Color.black
    }
    
    func clefWidth() -> CGFloat {
        return CGFloat(Double(lineSpacing) * 3.5)
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
        GeometryReader { geometry in
            let height = geometry.size.height
            let midPoint = Int(geometry.size.height/2)
            let width = Int(geometry.size.width)
            
            ZStack (alignment: .leading) {
                
//                ForEach(0..<score.staffLineCount){ row in
//                    Path { path in
//                        path.move(to: CGPoint(x: 0, y: row * Int(geometry.size.height/CGFloat(score.staffLineCount))))
//                        path.addLine(to: CGPoint(x: Int(geometry.size.width), y: row * Int(geometry.size.height/CGFloat(score.staffLineCount))))
//                        path.addLine(to: CGPoint(x: Int(geometry.size.width), y: row * Int(geometry.size.height/CGFloat(score.staffLineCount))+StaffView.lineHeight))
//                        path.addLine(to: CGPoint(x: 0, y: row * Int(geometry.size.height/CGFloat(score.staffLineCount))+StaffView.lineHeight))
//                        path.closeSubpath()
//                    }
//                    .fill(colr(line: row))
//                }
                
                // staff lines
                
                if staff.linesInStaff > 1 {
                    ForEach(-2..<3) { row in
                        Path { path in
                            let y = midPoint + (row * lineSpacing)
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        //.fill(Color(.black))
                        .stroke(Color.black, lineWidth: 1)
                    }
                }
                else {
                    Path { path in
                        let y = midPoint
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
                
                // end of staff bar lines
                
                Path { path in
                    let y = midPoint
                    path.move(to: CGPoint(x: Int(geometry.size.width)-2, y: Int(geometry.size.height)/2 + 2 * lineSpacing))
                    path.addLine(to: CGPoint(x: Int(geometry.size.width)-2, y: Int(geometry.size.height)/2 - 2 * lineSpacing))
                }
                .stroke(Color.black, lineWidth: Double(lineSpacing) / 3)

                HStack {
                    if true { //enable to check alingment - the X should be right on the center line of the staff
                        HStack {
                            Text("X")
                        }
                        .border(Color.blue)
                        .padding(.horizontal, 8)
                    }
                    
                    if staff.linesInStaff > 1 {
                        //Huge TODO - dont show treble for one line staff
                        //if the font size number is too big causing the staff view goes below the score view all the alingmnet of everything is screwed up
                        HStack {
                            if staff.type == StaffType.treble {
                                Text("\u{1d11e}")
                                    .font(.system(size: CGFloat(lineSpacing * 9)))
                                //.offset(y:CGFloat(0 - lineSpacing))
                            }
                            else {
                                Text("\u{1d122}")
                                    .font(.system(size: CGFloat(lineSpacing * 6)))
                                //.offset(y:CGFloat(0 - lineSpacing))
                            }
                        }
                        .frame(width: clefWidth())
                        //.border(Color.green)
                    }
                    
                    VStack(spacing: 0) {
                        //Need to squash numerator and denominator of time sig together to overidde default spacing of the text fields
                        //TODO same as above - too large of a font size screws al algnemnt of everythgn
                        let timeSignatureFontSize = CGFloat(Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.5))
                        let squash:CGFloat = CGFloat(lineSpacing)/2.5
                        Spacer()
                        Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: squash)
                        //padding required since these text fields down line up on the staff center line. So padding her to push entire time sig up
                        //Text("4").padding(.bottom, 1 * CGFloat(lineSpacing)).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                        Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                        Spacer()
                    }
                    .bold()
                    .frame(width: clefWidth())
                    .border(Color.red)
                    
//                    HStack (spacing: 0) {
//                        ForEach(0 ..< score.key.keySig.accidentalCount, id: \.self) { i in
//                            //KeySignatureAccidentalView(staff: staff, key:score.key.keySig, noteIdx: i, lineSpacing: score.lineSpacing)
//                        }
//                    }
//                    .border(Color.green)
//                    .frame(width: CGFloat(score.staffLineCount/2 * lineSpacing))
                    
                    if score.showNotes {
                        ForEach(score.scoreEntries, id: \.self) { entry in
                            VStack {
                                ZStack {
                                    if entry is TimeSlice {
                                        ForEach(getNotes(entry: entry), id: \.self) { note in
                                        //ForEach(entry as TimeSlice.note, id: \.self) { note in
                                            //if the note isn't shown on both staff's the alignment between staffs is wrong when >1 chord on the staff
                                            //so make a space on the staff where a time slice has notes only in one staff
                                            //if note.staff == staff.staffNum {
                                            NoteView(staff: staff,
                                                     note: note,
                                                     stemDirection: note.midiNumber < staff.middleNoteValue ? 0 : 1,
                                                     lineSpacing: lineSpacing,
                                                     opacity: 1)
                                            //                                        }
                                            //                                        else {
                                            //                                            NoteView(staff: staff,
                                            //                                                     note: note,
                                            //                                                     stemDirection: 0,
                                            //                                                     lineSpacing: lineSpacing,
                                            //                                                     opacity: 0)
                                            //                                        }
                                        }
                                    }
                                    if entry is BarLine {
                                        BarLineView(staff: staff, lineSpacing: lineSpacing)
                                    }
                                }
                                if score.showFootnotes {
                                    if staff.staffNum == 1 {
                                        //if let footNote = timeSlice.footnote {
                                            //Spacer()
                                            //UIHiliteText(text: footNote, answerMode: 1).padding(.top, 50)
                                            //Spacer()
                                        //}
                                    }
                                }
                            }
                            //.border(Color.green)
                        }
                    }
                }
            }
            //.border(Color.red)
        }
    }
    
}
