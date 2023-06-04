import SwiftUI
import CoreData

struct StemView: View {
    @State var score: Score
    @State var staff: Staff
    @State var note: Note
    @State var offsetFromStaffMiddle: Int
    @State var lineSpacing:Double
    @State var stemLength:Double
    @State var noteWidth:Double
    
    func stemDirection(note:Note) -> Double {
        if note.isOnlyRhythmNote {
            return -1.0
        }
        else {
            return note.midiNumber < 71 ? -1.0 : 1.0
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                let startNote = note.getBeamStartNote(score: score)

                if note.value != Note.VALUE_WHOLE {
                    //Note this code eventually has to go adjust the stem length for notes under a quaver beam
                    //3.5 lines is a full length stem
                    let stemDirection = stemDirection(note: note)
                    if stemDirection < 0 {
                        
                    }
                    let midX = geo.size.width / 2.0 + (stemDirection * -1.0 * noteWidth / 2.0)
                    let midY = geo.size.height / 2.0
                    let offsetY = Double(offsetFromStaffMiddle) * 0.5 * lineSpacing
                    Path { path in
                        path.move(to: CGPoint(x: midX, y: midY - offsetY))
                        path.addLine(to: CGPoint(x: midX, y: midY - offsetY + (stemDirection * stemLength)))
                    }
                    .stroke(Color.black, lineWidth: 1)
                }
            }
        }
    }
}

struct StaffNotesView: View {
    @State var score:Score
    @State var staff:Staff
    @State var lineSpacing:Double
    @State var first:Int? = nil
    @State var last:Int? = nil
    
    // for some unknwon reason must be shared since otherwise updates to it dont refresh the beams view
    //@ObservedObject var positionStore = NoteLayoutPositions.getShared()
    
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
    
    init(score:Score, staff:Staff, lineSpacing:Double) {
        self.score = score
        self.staff = staff
        self.lineSpacing = lineSpacing
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

    func noteOffsetFromMiddle(staff:Staff, note:Note) -> Int {
        let noteData = staff.getNoteViewData(noteValue: note.midiNumber)
        return noteData.0
    }
        
    func getBeamLine(endNote:Note, noteWidth:Double, startNote:Note, stemLength:Double) -> (CGPoint, CGPoint)? {
        var stemDirection:Double // = startNote.midiNumber < 71 ? -1.0 : 1.0
        if endNote.isOnlyRhythmNote {
            stemDirection = -1.0
        }
        else {
            stemDirection = endNote.midiNumber < 71 ? -1.0 : 1.0
        }
        //end note
        let endNotePos = positionStore.positions[endNote]
        if let endNotePos = endNotePos {
            let xEndMid = endNotePos.origin.x + endNotePos.size.width / 2.0 + (noteWidth / 2.0 * stemDirection * -1.0)
            let yEndMid = endNotePos.origin.y + endNotePos.size.height / 2.0
            
            let endPitchOffset = noteOffsetFromMiddle(staff: staff, note: endNote)
            let yEndNoteMiddle:Double = yEndMid + (Double(endPitchOffset) * lineSpacing * -0.5)
            let yEndNoteStemTip = yEndNoteMiddle + stemLength * stemDirection
            
            //start note
            let startNotePos = positionStore.positions[startNote]
            if let startNotePos = startNotePos {
                let xStartMid = startNotePos.origin.x + startNotePos.size.width / 2.0 + (noteWidth / 2.0 * stemDirection * -1.0)
                let yStartMid = startNotePos.origin.y + startNotePos.size.height / 2.0
                let startPitchOffset = noteOffsetFromMiddle(staff: staff, note: startNote)
                let yStartNoteMiddle:Double = yStartMid + (Double(startPitchOffset) * lineSpacing * -0.5)
                let yStartNoteStemTip = yStartNoteMiddle + stemLength * stemDirection
                let p1 = CGPoint(x:xEndMid, y: yEndNoteStemTip)
                let p2 = CGPoint(x:xStartMid, y:yStartNoteStemTip)
                print("-----------getBeamLine forEndNote", endNote.sequence, "pos count", positionStore.positions.count, "line", p1, p2)
                print("  endNote:", String(format: "%.3f", endNotePos.minX), " startNote", String(format: "%.3f", startNotePos.minX))
                return (p1, p2)
            }
        }
        return nil
    }
    
    var body: some View {
        ZStack { //ZStack - notes and quaver beam drawing shares same space
            let stemLength = (3.5 * lineSpacing)
            let noteWidth = lineSpacing * 1.2
            
            HStack(spacing: 0) { //HStack - score entries display along the staff
                ForEach(score.scoreEntries, id: \.self) { entry in
                    VStack { //VStack - required in forEach closure
                        if entry is TimeSlice {
                            ZStack { // Each note frame in the timeslice shares the same same space
                                ForEach(getNotes(entry: entry), id: \.self) { note in
                                    //render the note in both staffs to ensure all entries in both staffs line up vertically
                                    //if note.staff == nil || note.staff == staff.staffNum {
                                        GeometryReader { geo in
                                            ZStack {
                                                NoteView(staff: staff, note: note,
                                                         noteWidth: noteWidth, lineSpacing: lineSpacing,
                                                         offsetFromStaffMiddle: noteOffsetFromMiddle(staff: staff, note: note))
                                                .background(GeometryReader { geometry in
                                                    Color.clear
                                                        .onAppear {
                                                            if staff.staffNum == 0 {
                                                                self.positionStore.storePosition(note: note, rect: geometry.frame(in: .named("HStack")), cord: "HStack")
                                                            }
                                                        }
                                                })
                                            }
                                        }
                                    //}
                                }
                                if let note = getNote(entry: entry) {
                                    //if let staffNum = note.staff {
                                        //if staffNum == self.staff.staffNum {
                                    //if note.staff == nil || note.staff == staff.staffNum {
                                    StemView(score:score, staff:staff, note: note, offsetFromStaffMiddle: noteOffsetFromMiddle(staff: staff, note: note),
                                                 lineSpacing: lineSpacing, stemLength: stemLength, noteWidth: noteWidth)
                                    //}
                                        //}
                                    //}
                                }
                            }
                        }
                        if entry is BarLine {
                            BarLineView(entry: entry, staff: staff, lineSpacing: lineSpacing)
                        }
                    }
                    .coordinateSpace(name: "VStack")
                    //IMPORTANT - keep this since the quaver beam code needs to know exactly the note view width
                    //UPDATE - code now updated to allow variable length note views. now note requied :)
                    //.frame(width: frameWidth)
                }
                .coordinateSpace(name: "ForEach")
            }
            .coordinateSpace(name: "HStack")
            
            // ==================== Quaver beams =================
            if staff.staffNum == 0 {
                GeometryReader { geo in
                    ZStack {
                        ZStack {
                            ForEach(positionStore.positions.sorted(by: { $0.key.sequence < $1.key.sequence }), id: \.key) { endNote, endNotePos in
                                if endNote.beamType == .end {
                                    //let startNote = noteDrawDimensions.getBeamStartNote(score: score, endNote: endNote)
                                    let startNote = endNote.getBeamStartNote(score: score)
                                    if let line = getBeamLine(endNote: endNote, noteWidth: noteWidth, startNote: startNote, stemLength: stemLength) {
                                        Path { path in
                                            path.move(to: CGPoint(x: line.0.x, y: line.0.y))
                                            path.addLine(to: CGPoint(x: line.1.x, y: line.1.y))
                                        }
                                        .stroke(Color.blue, lineWidth: 2)
                                    }
                                }
                            }
                        }
                        .border(Color .blue)
                        .padding(.horizontal, 0)
                    }
                    .border(Color .orange)
                    .padding(.horizontal, 0)
                }
                .padding(.horizontal, 0)
                .border(Color .green)
            }
        }
        .coordinateSpace(name: "ZStack0")
        .onDisappear() {
            NoteLayoutPositions.reset()
        }
    }
        
}

//    func showGeoProxy(place:String, geo:GeometryProxy, note: Note){
//        if note.sequence >= 2 {
//            return
//        }
//        //We use the frame(in:) method on the GeometryProxy to obtain the frame of the parent view in the global coordinate space.
//        print ("\n====> ", place, "Seq", note.sequence, "\tGEO Size", geo.size, "\tFrame", geo.frame) //, geo.frame )
//        //print (geometry.frame(in: .global))
//        var parentFrame = geo.frame(in: .global)
//        print("   Parent Location: GLOBAL \(parentFrame.origin)")
//        let cgrect = parentFrame.origin
//        //let parentFrame1:CGRect = geo.frame(in: .local)
//        //print("   Parent Location: LOCAL \(parentFrame.origin)")
//
//        print("   Parent Location: ZStack0\t", geo.frame(in: .named("ZStack0")))
//        print("   Parent Location: ZStack00t", geo.frame(in: .named("ZStack00")))
//        print("   Parent Location: ZStack001t", geo.frame(in: .named("ZStack001")))
//
//        print("   Parent Location: ZStack01\t", geo.frame(in: .named("ZStack10")))
//        print("   Parent Location: ZStack010\t", geo.frame(in: .named("ZStack11")))
//    }

//                    ForEach(score.scoreEntries, id: \.self) { entry in
//                        if entry is TimeSlice {
//                            if let note = getNote(entry: entry) {
//                                if note.beamType == .end {
//                                    let startNote = noteDrawDimensions.getBeamStartNote(score: score, note: note)
//                                    let stemDirection:Double = startNote.midiNumber < 71 ? -1.0 : 1.0
//                                    let xOffset = frameWidth //* 0.45
//                                    let noteMidx = (frameWidth * Double(note.sequence)) + (frameWidth / 2.0) + xOffset
//
//                                    let noteMidy = geo.size.height/2.0 - Double(noteOffsetFromMiddle(note: note)) * lineSpacing / 2.0
//                                    let stemLength = (Double(lineSpacing) * 3.5 * stemDirection)
//
//                                    let startNoteMidx = (frameWidth / 1.0 * Double(startNote.sequence)) + (frameWidth / 2.0) + xOffset
//                                    let startNoteMidy = geo.size.height/2.0 - Double(noteOffsetFromMiddle(note: startNote)) * lineSpacing / 2.0
//                                    let xNoteOffset = stemDirection * -1.0 * noteWidth / 2.0
//
//                                    ForEach(positionStore.positions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                                        Ellipse()
//                                            .stroke(Color.red, lineWidth: 4)
//                                            .frame(width: 6, height: 6)
//                                            .position(x: value.origin.x, y: 0.0)
//                                    }
//
////                                    if positionStore.positions.count > 1 {
////                                        for i in 0..<2 {
////                                            Ellipse()
////                                                .stroke(Color.red, lineWidth: 4)
////                                                .frame(width: 6, height: 6)
////                                                .position(x: positionStore.positions[i]!.origin.x, y: 0.0)
////                                        }
////                                    }
////                                    //let pos = positionStore.positions[note.sequence] //x,y,width, height
//                                    //                                Ellipse()
//                                    //                                //Open ellipse
//                                    //                                    .stroke(Color.red, lineWidth: 4)
//                                    //                                    .frame(width: 6, height: 6)
//                                    //                                    .position(x: noteMidx, y: noteMidy)
//                                    //                                Path { path in
//                                    //                                    path.move(to: CGPoint(x: noteMidx, y: noteMidy + stemLength))
//                                    //                                    path.addLine(to: CGPoint(x: startNoteMidx, y: startNoteMidy + stemLength))
//                                    //                                }
//                                    //                                .stroke(Color.black, lineWidth: 4)
//                                    //                                .onAppear {
//                                    //                                    //showGeoProxy(place:"Beam", geo: geo, note:note)
//                                    //                                    print("On Appear", self.positionStore.positions)
//                                    //                                }
//                                }
//                            }
//                        }
//                    }
//                    .coordinateSpace(name: "ZStack010")
  
