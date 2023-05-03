import Foundation
import AVKit
import AVFoundation

//https://mammothmemory.net/music/sheet-music/reading-music/treble-clef-and-bass-clef.html

enum StaffType {
    case treble
    case bass
}

class StaffPlacement {
    var name:Character
    var offset:Int
    var acc: Int?
    init(name:Character, _ offset:Int, _ acc:Int?=nil) {
        self.offset = offset
        self.acc = acc
        self.name = name
    }
}

class StaffPlacementsByKey {
    var staffPlacement:[StaffPlacement] = []
}

class OffsetsInStaffByKey {
    var noteOffsetByKey:[String] = []
    init () {
        // offset, sign. sign = ' ' or 0=flat, 1=natural, 2=sharp
        //  Key                 C    D♭   D    E♭   E    F    G♭   G    A♭   A    B♭   B
        noteOffsetByKey.append("0    0    0,1  0    0,1  0    0,1  0    0    0,1  0    0,0")  //C
        noteOffsetByKey.append("0,2  1    0    1,0  0    1,0  1    0,2  1    0    1,0  0,0")  //C#
        noteOffsetByKey.append("1    1,1  1    1    1,1  1    1,1  1    1,1  1    1    0,0")  //D
        noteOffsetByKey.append("2,0  2    2,0  2    1    2,0  2    2,0  2    1,2  2    0,0")  //E♭
        noteOffsetByKey.append("2    2,1  2    2,1  2    2    2,1  2    2,1  2    2,1  0,0")  //E
        noteOffsetByKey.append("3    3    3,1  3    3,1  3    3    3,1  3    3,1  3    0,0")  //F
        noteOffsetByKey.append("3,2  4    3    4,0  3    4,0  4    3    4,0  3    4,0  0,0")  //F#
        noteOffsetByKey.append("4    4,1  4    4    4,1  4    4,1  4    4    4,1  4    0,0")  //G
        noteOffsetByKey.append("4,2  5    4,2  5    4    5,0  5    4,2  5    4    5,0  0,0")  //G#
        noteOffsetByKey.append("5    5,1  5    5,1  5    5    5,1  5    5,1  5    5    0,0")  //A
        noteOffsetByKey.append("6,0  6    6,0  6    6,0  6    6    6,0  6    6,0  6    0,0")  //B♭
        noteOffsetByKey.append("6    6,1  6    6,1  6    6,1  6,1  6    6,1  6    6,1  0,0")  //B
    }
}

class Staff : ObservableObject {
    @Published var publishUpdate = 0
    let score:Score
    var type:StaffType
    var staffNum:Int
    var noteOffsets:[StaffPlacementsByKey] = []
    let linesInStaff = 5
    var lowestNoteValue:Int
    var highestNoteValue:Int
    var staffOffsets:[Int] = []
    
    init(score:Score, type:StaffType, staffNum:Int) {
        self.score = score
        self.type = type
        self.staffNum = staffNum
        lowestNoteValue = 0
        highestNoteValue = 88

        if type == StaffType.treble {
            if score.ledgerLineCount == 0 {
                lowestNoteValue = 44
            }
            if score.ledgerLineCount == 1 {
                lowestNoteValue = 40
            }
            if score.ledgerLineCount == 2 {
                lowestNoteValue = 37
            }
            if score.ledgerLineCount == 3 {
                lowestNoteValue = 33
            }
            if score.ledgerLineCount == 4 {
                lowestNoteValue = 30
            }
        }
        else {
            if score.ledgerLineCount == 0 {
                lowestNoteValue = 23
            }
            if score.ledgerLineCount == 1 {
                lowestNoteValue = 20
            }
            if score.ledgerLineCount == 2 {
                lowestNoteValue = 16
            }
            if score.ledgerLineCount == 3 {
                lowestNoteValue = 13
            }
            if score.ledgerLineCount == 4 {
                lowestNoteValue = 9
            }
        }
        
        noteOffsets = [StaffPlacementsByKey](repeating: StaffPlacementsByKey(), count: highestNoteValue + 1)
        var noteIdx = 4
        let offsetsInStaffByKey = OffsetsInStaffByKey()
        var allDone = false
        var octaveCtr = 0
        var nameCtr = 2
        var lastOffset:Int? = nil

        while !allDone {
            for line in offsetsInStaffByKey.noteOffsetByKey {
                let sp = StaffPlacementsByKey()
                let pairs = line.components(separatedBy: " ")
                let octave = ((octaveCtr) / 12) - (self.type == StaffType.treble ? 3 : 1)
                octaveCtr += 1
                var col = 0
                
                for pair in pairs {
                    if pair.isEmpty {
                        continue
                    }
                    let noteParts = pair.trimmingCharacters(in: .whitespaces).components(separatedBy: ",")
                    let staffTypeOffset = type == StaffType.treble ? 0 : -2
                    let staffOffset = Int(noteParts[0])! + (octave * 7) + ((score.ledgerLineCount - 1) * 2) + staffTypeOffset
                    
                    if col == 0 {
                        if let lastOffset = lastOffset {
                            if staffOffset != lastOffset {
                                nameCtr += 1
                            }
                        }
                        lastOffset = staffOffset
                    }
                    col += 1
                    
                    let noteName = Note.staffNoteName(idx: nameCtr)

                    let note = StaffPlacement(name: noteName, staffOffset)
                    if noteParts.count > 1 {
                        note.acc = Int(noteParts[1])!
                    }
                    sp.staffPlacement.append(note)
                }

                if noteIdx < noteOffsets.count {
                    noteOffsets[noteIdx] = sp
                    noteIdx += 1
                }
                else {
                    allDone = true
                    break
                }
            }
        }
    }
    
    func keyDescription() -> String {
        return self.score.key.description()
    }
    
    func update() {
        DispatchQueue.main.async {
            self.publishUpdate += 1

        }
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.publishUpdate = 0
        }
    }

    func show(_ lbl:String) {
        for n in stride(from: noteOffsets.count-1, to: 0, by: -1) {
            let sp = noteOffsets[n]
            if sp.staffPlacement.count > 0 {
                var acc = ""
                if sp.staffPlacement[0].acc == 0 {acc = Score.accFlat}
                if sp.staffPlacement[0].acc == 1 {acc = Score.accNatural}
                if sp.staffPlacement[0].acc == 2 {acc = Score.accSharp}
                print("\(lbl) Note", n,
                      "\(sp.staffPlacement[0].offset) \(sp.staffPlacement[0].name) \(acc)")
            }
        }
    }
    
    func keyColumn() -> Int {
        //    Key   C    D♭   D    E♭   E    F    G♭   G    A♭   A    B♭   B
        //m.append("0    0    0,0  0    0,0  0    0    0    0    0,0  0    0,0")  //C

        if score.key.keySig.accidentalType == AccidentalType.sharp {
            switch score.key.keySig.accidentalCount {
            case 0:
                return 0
            case 1:
                return 7
            case 2:
                return 2
            case 3:
                return 9
            case 4:
                return 4
            case 5:
                return 11
            case 6:
                return 6
            case 7:
                return 1
            default:
                return 0
            }
        }
        else {
            switch score.key.keySig.accidentalCount {
            case 0:
                return 0
            case 1:
                return 5
            case 2:
                return 10
            case 3:
                return 3
            case 4:
                return 8
            case 5:
                return 1
            case 6:
                return 6
            case 7:
                return 11
            default:
                return 0
            }
        }
     }
    
    //Tell a note how to display itself
    func getNoteViewData(noteValue:Int) -> (Int?, String, [Int]) {
        let staffPosition = self.noteOffsets[noteValue]
        let keyCol = keyColumn()
        let offsetFromBottom = staffPosition.staffPlacement[keyCol].offset
        let offsetFromTop = (score.staffLineCount * 2) - offsetFromBottom - 2

        var ledgerLines:[Int] = []
        if abs(offsetFromBottom) <= score.ledgerLineCount*2 - 2 {
            let onSpace = abs(offsetFromBottom) % 2 == 1
            var lineOffset = 0
            if onSpace {
                lineOffset -= 1
            }
            for _ in 0..<(score.ledgerLineCount - offsetFromBottom/2) + lineOffset {
                ledgerLines.append(lineOffset)
                lineOffset -= 2
            }
        }
        if abs(offsetFromTop) <= score.ledgerLineCount*2 - 2 {
            let onSpace = abs(offsetFromTop) % 2 == 1
            var lineOffset = 0
            if onSpace {
                lineOffset += 1
            }
            for _ in 0..<(score.ledgerLineCount - offsetFromTop/2) - lineOffset {
                ledgerLines.append(lineOffset)
                lineOffset += 2
            }
        }
        var acc = ""
        switch staffPosition.staffPlacement[keyCol].acc {
            case 0:
                acc=Score.accFlat
            case 1:
                acc=Score.accNatural
            case 2:
                acc=Score.accSharp
            default:
                acc=""
        }
        return (offsetFromTop, acc, ledgerLines)
    }
    
}
 
