import SwiftUI
import CoreData
import MessageUI

struct FeedbackView: View {
    @ObservedObject var score:Score
    var body: some View {
        HStack {
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
                if let index = studentFeedback.indexInError {
                        Text("Wrong rhythm here at note: \(index)").padding()
                }
            }
        }
        if let studentFeedback = score.studentFeedback {
            if let feedbackExplanation = studentFeedback.feedbackExplanation {
                VStack {
                    Text(feedbackExplanation)
                        .lineLimit(nil)
                }
            }
            if let feedbackNote = studentFeedback.feedbackNote {
                VStack {
                    Text(feedbackNote)
                        .lineLimit(nil)
                }
            }
        }
    }
}

struct ScoreView: View {
    @ObservedObject var score:Score
    var parentGeometry:GeometryProxy
    
    func getLineSpacing(geo: GeometryProxy) -> CGFloat {
        let lineSpacing = UIDevice.current.userInterfaceIdiom == .phone ? 10.0 : geo.size.width / 64.0 //16.0 //was 10 , TODO dont hard code
        print("ScoreView body::", "totalWidth:", geo.size.width, "linespacing:", lineSpacing)
        return lineSpacing
    }
    
    var body: some View {
        GeometryReader { geo in
            let lineSpacing = LineSpacing(value: getLineSpacing(geo: geo))

            VStack {
                
                FeedbackView(score: score)
                
                ForEach(score.getStaff(), id: \.self.type) { staff in
                    if staff.score.hiddenStaffNo == nil || staff.score.hiddenStaffNo != staff.staffNum {
                        StaffView(score: score, staff: staff, lineSpacing: lineSpacing)
                            .frame(height: CGFloat(Double(score.staffLineCount) * lineSpacing.value))  //fixed size of height for all staff lines + ledger lines
                    }
                }
            }
            .coordinateSpace(name: "Score1")
            .overlay(
                RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
            )
            .background(UIGlobals.backgroundColor)
            .frame(height: CGFloat(Double(score.staffLineCount) * getLineSpacing(geo: geo)))
            //.border(Color .green)
        }
        //.coordinateSpace(name: "Score2")
    }
}
