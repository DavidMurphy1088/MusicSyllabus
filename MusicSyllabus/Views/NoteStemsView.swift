import SwiftUI
import CoreData

struct StemView: View {
    @State var note: Note
    @State var offsetFromStaffMiddle: Int
    @State var lineSpacing:Double

    var body: some View {
        GeometryReader { geo in
            VStack {
                if note.value != Note.VALUE_WHOLE {
                    //Note this code eventually has to go to the code that draws quaver beams since a quaver beam can shorten/lengthen the note stem
                    //3.5 lines is a full length stem
                    let midX = geo.size.width / 2.0
                    let midY = geo.size.height / 2.0
                    let ff = offsetFromStaffMiddle
                    let fg = lineSpacing
                    let offsetY = Double(offsetFromStaffMiddle) * 0.5 * lineSpacing
                    let stemDir = note.midiNumber < 71 ? -1 : 1
                    Path { path in
                        path.move(to: CGPoint(x: midX, y: midY - offsetY))
                        path.addLine(to: CGPoint(x: midX, y: midY - offsetY + (Double(stemDir) * 3.5 * lineSpacing)))
                    }
                    .stroke(Color.red, lineWidth: 1)
                    .border(Color.green)
                }
            }
        }
    }
}

struct NoteStemsView: View {
    @State var score:Score
    @State var staff:Staff
    @State var lineSpacing:Double
    //@State var frameWidth:Double
    @State var first:Int? = nil
    @State var last:Int? = nil
    @State var frameWidth = 70.0
    
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
    
    func getNote(entry:ScoreEntry) -> Note? {
        if entry is TimeSlice {
            if let notes = entry.getNotes() {
                if notes.count > 0 {
                    return notes[0]
                }
            }
        }
        return nil
    }
    
    func noteOffsetFromMiddle1() -> Int {
        return 0
    }

    func noteOffsetFromMiddle(note:Note) -> Int {
        let noteData = staff.getNoteViewData(noteValue: note.midiNumber)
        return noteData.0
    }
    
    func showGeoProxy(place:String, geo:GeometryProxy, note: Note){
        //We use the frame(in:) method on the GeometryProxy to obtain the frame of the parent view in the global coordinate space.
        print ("\n====> ", note.sequence, place, "GEO Size", geo.size, "Frame", geo.frame) //, geo.frame )
        //print (geometry.frame(in: .global))
        var parentFrame = geo.frame(in: .global)
        print("   ====> Parent Location: GLOBAL \(parentFrame.origin)")
        parentFrame = geo.frame(in: .local)
        print("   ====> Parent Location: LOCAL \(parentFrame.origin)")
        
        parentFrame = geo.frame(in: .named("Stems"))
        print("   ====> Parent Location: STEMS  \(parentFrame.origin)")
    }
    
    var body: some View {
        //GeometryReader { geometry in
        ZStack { //ZStack - notes and quaver beam drawing shares same space
            HStack(spacing: 0) { //HStack - score entries display along the staff
                ForEach(score.scoreEntries, id: \.self) { entry in
                    VStack { //VStack - required in forEach closure
                        if entry is TimeSlice {
                            ZStack { // Each note frame in the timeslice shares the same same space
                                ForEach(getNotes(entry: entry), id: \.self) { note in
                                    if note.staff == nil || note.staff == staff.staffNum {
                                        GeometryReader { geo in
                                            ZStack {
                                                NoteView(staff: staff, note: note,
                                                         noteWidth: lineSpacing * 1.2, lineSpacing: lineSpacing,
                                                         offsetFromStaffMiddle: noteOffsetFromMiddle(note: note))
                                            }
                                            .onAppear {
                                                showGeoProxy(place:"Note", geo: geo, note:note)
                                            }
                                        }
                                        
                                    }
                                }
                                if let note = getNote(entry: entry) {
                                    StemView(note: note, offsetFromStaffMiddle: noteOffsetFromMiddle(note: note), lineSpacing: lineSpacing)
                                }
                            }
                        }
                    }
                    .frame(width: frameWidth)  //IMPORTANT - keep this since the bea view needs to know exactly the note view width
                }
            }
            //"(TS,3,4) (72,.5) (72,.5) (72,2) (72,.5) (76,.5) (71,2) (72,.5) (65,.5) (71,2) "
            ForEach(score.scoreEntries, id: \.self) { entry in
                if entry is TimeSlice {
                    if let note = getNote(entry: entry) {
                        if note.beamType == .end {
                            let midX = (frameWidth / 1.0 * Double(note.sequence)) + (frameWidth / 2.0) + 41.0
                            let midY = 100.0 //frameWidth * Double(note.sequence) + frameWidth / 2.0
                            GeometryReader { geo in
                                Text("Q")
                                .onAppear {
                                    showGeoProxy(place:"BEam", geo: geo, note:note)
                                }
                                Ellipse()
                                //Open ellipse
                                    .stroke(Color.red, lineWidth: 4)
                                    .frame(width: 6, height: 6)
                                    .position(x: midX, y: midY)
                                Path { path in
                                    path.move(to: CGPoint(x: midX, y: midY))
                                    path.addLine(to: CGPoint(x: midX - 20, y: midY))
                                }
                                .stroke(Color.green, lineWidth: 4)
                            }
                            .border(Color.orange)
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "Stems")
    }
}
