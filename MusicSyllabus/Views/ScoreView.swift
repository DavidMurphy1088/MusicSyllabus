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
                        Text("Wrong rhythm here")// at note: \(index)").padding()
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
    @ObservedObject var lineSpacing:LineSpacing

    init(score:Score) {
        self.score = score
        self.lineSpacing = LineSpacing(value: UIDevice.current.userInterfaceIdiom == .phone ? 10.0 : UIScreen.main.bounds.width / 64.0)
        //self.setOrientationLayout()
        //print("SCORE VIEW INIT", "width::", UIScreen.main.bounds.width, "line spacing", lineSpacing.value)
    }
    
    func getFrameHeight() -> Double {
        var staffHeight:Double = self.staffHeight() //Double(score.staffLineCount) * Double(self.lineSpacing.value)
//        if score.staffs.count > 1 {
//            staffHeight = 2 * staffHeight + staffHeight / 2.0
//        }
        return staffHeight
    }
    
    func staffHeight() -> Double {
        return Double(score.getTotalStaffLineCount() + 1) * lineSpacing.value
    }
                
    func setChangeOrientationLayout() {
        //Absolutley no idea - the width reported here decreases in landscape mode so use height (which increases)
        //https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation
        let ls = UIDevice.current.userInterfaceIdiom == .phone ? 10.0 : UIScreen.main.bounds.height / 64.0
        print("SET ORIENTATION", "width::", UIScreen.main.bounds.width, "heght:", UIScreen.main.bounds.height, "line spacing", ls)
        self.lineSpacing.setValue(ls)
    }
    
    var body: some View {
        VStack {
            
            FeedbackView(score: score)
            
            ForEach(score.getStaff(), id: \.self.type) { staff in
                if staff.score.hiddenStaffNo == nil || staff.score.hiddenStaffNo != staff.staffNum {
                    StaffView(score: score, staff: staff, staffHeight: staffHeight(), lineSpacing: lineSpacing)
                        //.frame(height: staffHeight())  //fixed size of height for all staff lines + ledger lines
                }
            }
        }
        .onAppear {
            self.lineSpacing.value = UIDevice.current.userInterfaceIdiom == .phone ? 10.0 : UIScreen.main.bounds.width / 64.0
            //setOrientationLayout()
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { orientation in
            if UIDevice.current.orientation.isLandscape {
                print("--->Landscape", UIScreen.main.bounds)
            }
            else {
                print("--->Portrait", UIScreen.main.bounds)
            }
            setChangeOrientationLayout()
         }
        .onDisappear {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        .coordinateSpace(name: "Score1")
        .overlay(
            RoundedRectangle(cornerRadius: UIGlobals.cornerRadius).stroke(Color(UIGlobals.borderColor), lineWidth: UIGlobals.borderLineWidth)
        )
        .background(UIGlobals.backgroundColor)
        //.frame(height: getFrameHeight())
        .border(Color .green, width: 3)
    }

}

