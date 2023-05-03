import SwiftUI
import CoreData


struct PianoKeyboard: View {
    let whiteKeyCount = 7
    
    class Key : ObservableObject {
        var pitch: Int
        var pressed: Bool = false
        init(pitch:Int) {
            self.pitch = pitch
        }
    }
    @State var whiteKeys:[Key] = []

    init() {
        print("===>", whiteKeyCount)
        for i in 0..<whiteKeyCount {
            whiteKeys.append(Key(pitch: Note.MIDDLE_C + i*2))
            print("===", i)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let edgePadding = geometry.size.width * 0.1
            let whiteKeyWidth:CGFloat = (geometry.size.width - 2 * edgePadding) / CGFloat(whiteKeyCount)
            let whiteKeyHeight:CGFloat = geometry.size.height / 2.0
            let blackKeyWidth:CGFloat = whiteKeyWidth * 8/10
            let blackKeyHeight:CGFloat = whiteKeyHeight * 1/2

            ForEach(0..<whiteKeyCount) { col in
                Rectangle()
                .foregroundColor(whiteKeys[col].pressed ? .gray : .white)
                .overlay(
                    ZStack {
                        Text("\(whiteKeys[col].pitch)")
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                    }
                )
                .frame(width: whiteKeyWidth, height: whiteKeyHeight)
                .position(x: edgePadding + (CGFloat(col) * whiteKeyWidth) + whiteKeyWidth/2, y: whiteKeyHeight/2) //.pos is center of rect
                .onTapGesture {
                    DispatchQueue.global(qos: .userInitiated).async {
                        SoundGenerator.soundGenerator.playNote(notePitch: self.whiteKeys[col].pitch)
                        for k in whiteKeys {
                            k.pressed = false
                        }
                        whiteKeys[col].pressed = true
                        //print(whiteKeys)
                    }
                }
            }
            
            ForEach(0..<whiteKeyCount-1) { col in
                if col != 2 {
                    Rectangle()
                        .foregroundColor(.black)
                    //                .overlay(
                    //                    Rectangle()
                    //                        .stroke(Color.black, lineWidth: 2)
                    //                )
                        .frame(width: blackKeyWidth, height: blackKeyHeight)
                        .position(x: edgePadding + (CGFloat(col+1) * whiteKeyWidth) + whiteKeyWidth/2 - blackKeyWidth/2 - 1, y: blackKeyHeight/2) //.pos is center of rect
                }
            }

        }

    }
    
    var body1: some View {
        GeometryReader { geometry in
            let keyWidth:Int = Int(geometry.size.width) / whiteKeyCount
            let gap:Int = keyWidth * 2/10
            let keyHeight:Int = Int(geometry.size.height / 2.0)
            ZStack {
                ForEach(0..<whiteKeyCount) { col in
                    Path { path in
                        path.move(to: CGPoint(x: col * keyWidth, y: 0))
                        path.addLine(to: CGPoint(x: col * keyWidth - gap, y: 0))
                        path.addLine(to: CGPoint(x: col * keyWidth - gap, y: keyHeight))
                        path.addLine(to: CGPoint(x: col * keyWidth, y: keyHeight))
                        //path.addRect(CGRect(origin: CGPoint(x: col*Int(keyWidth),y: 0), size: CGSize(width: keyWidth , height: keyHeight)))
                        path.closeSubpath()
                    }
                    //.fill(Color.blue)
                }
            }
        }
    }
}
