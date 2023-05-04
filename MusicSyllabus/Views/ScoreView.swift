import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    @ObservedObject var score:Score
    
    var body: some View {
        VStack {
            HStack {
                Text("\(score.keyDesc())").bold() //.font(.system(size: CGFloat(lineSpacing)))
                Spacer()
                Button(action: {
                    score.toggleShowNotes()
                }) {
                    if score.showNotes {
                        Image(systemName: "multiply.circle")
                            .scaleEffect(2.0)
                    }
                    else {
                        Image(systemName: "plus.circle")
                            .scaleEffect(2.0)
                    }
                }
            }
            .padding()
            ForEach(score.getStaff(), id: \.self.type) { staff in
                StaffView(score: score, staff: staff)
                    .frame(height: CGFloat(score.staffLineCount * score.lineSpacing)) //fixed size of height for all staff lines + ledger lines
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(.blue, lineWidth: 2)
        )
        .background(Color.blue.opacity(0.04))
    }
}
