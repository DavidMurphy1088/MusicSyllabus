import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    @ObservedObject var score:Score
    let lineSpacing = 10 //was 10 , TODO dont hard code

    var body: some View {
        VStack {
//            HStack {
//                Text("\(score.keyDesc())").bold() //.font(.system(size: CGFloat(lineSpacing)))
//                Spacer()
//                if false {
//                    Button(action: {
//                        score.toggleShowNotes()
//                    }) {
//                        if score.showNotes {
//                            Image(systemName: "multiply.circle")
//                                .scaleEffect(2.0)
//                        }
//                        else {
//                            Image(systemName: "plus.circle")
//                                .scaleEffect(2.0)
//                        }
//                    }
//                }
//            }
//            .padding()
            HStack {
                ForEach(score.getStaff(), id: \.self.type) { staff in
                    StaffView(score: score, staff: staff, lineSpacing: lineSpacing)
                        .frame(height: CGFloat(score.staffLineCount * lineSpacing)) //fixed size of height for all staff lines + ledger lines
                }
            }.padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(.blue, lineWidth: 1)
        )
        .background(Color.blue.opacity(0.04))
        //.border(Color.pink)
    }
}
