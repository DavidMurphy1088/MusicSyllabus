import SwiftUI
import CoreData
import MessageUI

struct QuaverBeamView: View {
    var note:Note
    var body: some View {
        VStack {
            Spacer()
            Text(note.value == Note.VALUE_QUAVER ? "Q" : "")
        }
    }
}

struct StaffLinesView: View {
    @ObservedObject var staff:Staff
    var parentGeometry: GeometryProxy
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
                Path { path in
                    //let y:Double = Double(geometry.size.height) / 2.0
                    let x:Double = geometry.size.width - 2.0
                    let top:Double = (geometry.size.height/2.0) + Double(2 * lineSpacing)
                    let bottom:Double = (geometry.size.height/2.0) - Double(2 * lineSpacing)
                    path.move(to: CGPoint(x: x, y: top))
                    path.addLine(to: CGPoint(x: x, y: bottom))
                }
                .stroke(Color.black, lineWidth: Double(lineSpacing) / 3)
            }
        }
    }
}

struct TimeSignatureView: View {
    @ObservedObject var staff:Staff
    var parentGeometry: GeometryProxy
    var lineSpacing:Int
    var clefWidth:Double
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                //Need to squash numerator and denominator of time sig together to overidde default spacing of the text fields
                //TODO same as above - too large of a font size screws al algnemnt of everythgn
                let timeSignatureFontSize:Double = Double(lineSpacing) * (staff.linesInStaff == 1 ? 2.2 : 2.5)
                let squash:CGFloat = CGFloat(lineSpacing)/2.5
                Spacer()
                Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: squash)
                //padding required since these text fields down line up on the staff center line. So padding her to push entire time sig up
                //Text("4").padding(.bottom, 1 * CGFloat(lineSpacing)).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                Text("4").padding(.all, 0).font(.system(size: timeSignatureFontSize)).offset(x: 0, y: -squash)
                Spacer()
            }
            .bold()
            .frame(width: clefWidth)
        }
    }
}

struct StaffView: View {
    @ObservedObject var score:Score
    @ObservedObject var staff:Staff
    
    var lineSpacing:Int
    
    init (score:Score, staff:Staff, lineSpacing:Int) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
    }
    
    func clefWidth() -> Double {
        return Double(lineSpacing) * 3.5
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
            ZStack (alignment: .leading) {
                StaffLinesView(staff: staff, parentGeometry: geometry, lineSpacing: lineSpacing)
                HStack {
                    HStack {
                        if staff.type == StaffType.treble {
                            Text("\u{1d11e}").font(.system(size: CGFloat(lineSpacing * 9)))
                        }
                        else {
                            Text("\u{1d122}").font(.system(size: CGFloat(lineSpacing * 6)))
                        }
                    }
                    .frame(width: clefWidth())
                    //.border(Color.green)
                    TimeSignatureView(staff: staff, parentGeometry: geometry, lineSpacing: lineSpacing, clefWidth: clefWidth())
                    ForEach(score.scoreEntries, id: \.self) { entry in
                        ZStack {
                            if entry is TimeSlice {
                                ForEach(getNotes(entry: entry), id: \.self) { note in
                                    VStack {
                                        //if the note isn't shown on both staff's the alignment between staffs is wrong when >1 chord on the staff
                                        //so make a space on the staff where a time slice has notes only in one staff
                                        NoteView(staff: staff,
                                                 note: note,
                                                 stemDirection: note.midiNumber < staff.middleNoteValue ? 0 : 1,
                                                 lineSpacing: lineSpacing,
                                                 opacity: 1.0)
                                    }
                                }
                                QuaverBeamView(note: getNotes(entry: entry)[0])

                            }
                            if entry is BarLine {
                                BarLineView(entry:entry, staff: staff, lineSpacing: lineSpacing)
                            }
                        }
                    }
                    //.border(Color.green)
                }
            }
            
        }
    }
}
