import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    @ObservedObject var score:Score
    let lineSpacing = UIDevice.current.userInterfaceIdiom == .phone ? 10.0 : 16.0 //was 10 , TODO dont hard code

    var body: some View {
        VStack {
            HStack {
                if let label = score.label {
                    Text(label).padding()
                }
                if let studentFeedback = score.studentFeedback {
                    if studentFeedback.correct {
                        Image(systemName: "checkmark.circle")
                            .scaleEffect(2.0)
                            .foregroundColor(Color.green)
                            .padding()
                    }
                    else {
                        Image(systemName: "xmark.octagon")
                            .scaleEffect(2.0)
                            .foregroundColor(Color.red)
                            .padding()
                    }
                    if let feedback = studentFeedback.feedback {
                        Text(feedback).padding()
                            
                    }
                    if let tempo = studentFeedback.tempo {
                        Text("Tempo:\(tempo)").padding()
                    }
                }
            }
            ForEach(score.getStaff(), id: \.self.type) { staff in
                if staff.score.hiddenStaffNo == nil || staff.score.hiddenStaffNo != staff.staffNum {
                    StaffView(score: score, staff: staff, lineSpacing: lineSpacing)
                        .frame(height: CGFloat(Double(score.staffLineCount) * lineSpacing))  //fixed size of height for all staff lines + ledger lines
                }
            }
            .padding(.vertical, CGFloat(lineSpacing) * 2.0)
        }
        .padding(.horizontal, (score.scoreEntries.count > 10 && UIDevice.current.userInterfaceIdiom == .phone)  ? 0 : 12)
        .coordinateSpace(name: "Score1")
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)

        //.coordinateSpace(name: "Score2")
    }
}
