import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            //DegreeTriadsView()
            IntervalsView()
            .tabItem {
                Label("Triad", image: "triads")
            }
            
//            IntervalView()
//            .tabItem {
//                Label("Intervals", image: "intervals")
//            }

        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}




