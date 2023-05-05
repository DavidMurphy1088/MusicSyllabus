import SwiftUI
import CoreData
import MessageUI
 
struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff
    
    static let lineHeight = 1
    let lineHeight = 10
    
    init (score:Score, staff:Staff) {
        self.score = score
        self.staff = staff
    }
            
    func colr(line: Int) -> Color {
        if line < score.ledgerLineCount || line >= score.ledgerLineCount + 5 {
            return Color.yellow
        }
        return Color.black
    }
    
    func clefWidth() -> CGFloat {
        print("====TS:", score.timeSlices.count)
        return CGFloat(score.staffLineCount/3 * score.lineSpacing)
    }
    
    func clefHeight() -> CGFloat {
        return CGFloat((score.staffLineCount-1) * score.lineSpacing)
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
                
                ForEach(-2..<3){ row in
                    Path { path in
                        let y = midPoint + (row * lineHeight)
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    //.fill(Color(.black))
                    .stroke(Color.black, lineWidth: 1)
                }

                HStack {
                    HStack {
                        //spacing only
                    }
                    //.border(Color.blue)
                    .padding(.horizontal, 8)
                    
                    HStack {
                        if staff.type == StaffType.treble {
                            Text("\u{1d11e}").font(.system(size: CGFloat(score.lineSpacing * 9)))
                                .offset(y:CGFloat(0 - score.lineSpacing))
                        }
                        else {
                            Text("\u{1d122}").font(.system(size: CGFloat(score.lineSpacing * 6)))
                                .offset(y:CGFloat(0 - score.lineSpacing))
                        }
                    }
                    //.border(Color.green)
                    .frame(width: clefWidth())
                    
                    VStack {
                        Text("4")
                        Text("4")
                    }
                    .bold()
                    .frame(height: clefHeight())

                    HStack (spacing: 0) {
                        ForEach(0 ..< score.key.keySig.accidentalCount, id: \.self) { i in
                            //KeySignatureAccidentalView(staff: staff, key:score.key.keySig, noteIdx: i, lineSpacing: score.lineSpacing)
                        }
                    }
                    //.border(Color.red)
                    .frame(width: CGFloat(score.staffLineCount/2 * score.lineSpacing))
                    
                    if score.showNotes {
                        ForEach(score.timeSlices, id: \.self) { timeSlice in
                            VStack {
                                ZStack {
                                    ForEach(timeSlice.note, id: \.self) { note in
                                        //if the note isn't shown on both staff's the alignment between staffs is wrong when >1 chord on the staff
                                        //so make a space on the staff where a time slice has notes only in one staff
                                        if note.staff == staff.staffNum {
                                            NoteView(staff: staff,
                                                     note: note,
                                                     stemDirection: note.num < staff.middleNoteValue ? 0 : 1,
                                                     lineSpacing: score.lineSpacing,
                                                     opacity: 1)
                                        }
                                        else {
                                            NoteView(staff: staff,
                                                     note: note,
                                                     stemDirection: 0,
                                                     lineSpacing: score.lineSpacing,
                                                     opacity: 0)
                                        }
                                    }
                                }
                                if score.showFootnotes {
                                    if staff.staffNum == 1 {
                                        if let footNote = timeSlice.footnote {
                                            //Spacer()
                                            //UIHiliteText(text: footNote, answerMode: 1).padding(.top, 50)
                                            //Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //.border(Color.pink)
        }
    }
}
