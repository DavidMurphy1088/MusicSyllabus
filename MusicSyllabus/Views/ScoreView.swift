import SwiftUI
import CoreData
import MessageUI
 
struct ScoreView: View {
    @ObservedObject var score:Score
    let lineSpacing:Int = UIDevice.current.userInterfaceIdiom == .phone ? 10 : 16 //was 10 , TODO dont hard code

    var body: some View {
        //VStack {
            VStack {
                if let label = score.label {
                    Text(label)
                }
                ForEach(score.getStaff(), id: \.self.type) { staff in
                    if staff.score.hiddenStaffNo == nil || staff.score.hiddenStaffNo != staff.staffNum {
                        StaffView(score: score, staff: staff, lineSpacing: lineSpacing)
                            .frame(height: CGFloat(Double(score.staffLineCount * lineSpacing)))  //fixed size of height for all staff lines + ledger lines
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

        //}
        //.coordinateSpace(name: "Score2")
        //.padding(.vertical)
    }
}
