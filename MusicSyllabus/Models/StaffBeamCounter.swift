import SwiftUI
import CoreData
import MessageUI

class StaffQuaverBeamCounter : ObservableObject  {
    let id = UUID()
    var notePositions:[(Note, CGRect)] = []
    var rotationOccured = false
    //var staff:Staff
    
    @Published var updated:Int = 0
    
    //sometimes getNotes() returns a zero length array. The below is a hack to fix this but needs correcting
    //static
    var lastNonZeroPostions:[(Note, Note, CGRect, CGRect)] = [] //TOOD FIX!!!
    
    init() {
        //print("--BeamCounter created, ID:", String(self.id.uuidString.suffix(4)))
        //self.staff = staff
    }
    
    func add(p: (Note, CGRect)) {
        for n in notePositions { //TODO remove
            if n.0.id == p.0.id {
//                print("================== duplicated id", p.0.id)
//                if rotationOccured {
//                    self.notePositions = []
//                    self.rotationOccured = false
//                }
//                else {
                    return
                //}
            }
        }
//        if p.0.sequence == 0 {
//            print ("--------------------- new Adding COUNT:", self.notePositions.count)
//        }
        self.notePositions.append(p)
        //print("    -- BeamCtr ADD ", "type:", type(of: p.1), "midi", p.0.midiNumber, "\tseq:", p.0.sequence, "\tBeam:", p.0.beamType, "id:", self.id)
        DispatchQueue.main.async {
            self.updated += 1
        }
    }
    
    func getNotes() -> [(Note, Note, CGRect, CGRect)] {
        var positions:[(Note, Note, CGRect, CGRect)] = []
        self.notePositions = notePositions.sorted(by: { $0.0.sequence < $1.0.sequence })
        if notePositions.count > 1 {
            for i in 0..<notePositions.count-1 {
                //print("==== BeamCtr GET notes\t", notes[i].0.beamType, notes[i].0.midiNumber, "\tX:", notes[i].1.origin.x)
                positions.append((notePositions[i].0, notePositions[i+1].0, notePositions[i].1, notePositions[i+1].1))
            }
        }
        
        var result = positions
        if result.count > 0 {
            lastNonZeroPostions = result.map { $0 }
            //print("====Beam Ctr", result.count)
        }
        else {
            result = lastNonZeroPostions
        }
        //print("  -- Beam Ctr id:", String(self.id.uuidString.suffix(4)), "->result", result, "count:", result.count)

        return result
    }
}
