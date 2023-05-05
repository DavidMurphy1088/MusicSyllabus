import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            IntervalsView()
            .tabItem {
                Label("Piano", image: "triads")
            }
            
            //DegreeTriadsView()
//            TopicsView(title: "Musicianship", topics: TopicList().topics)
//            .tabItem {
//                Label("Topics", image: "triads")
//            }


//            IntervalView()
//            .tabItem {
//                Label("Intervals", image: "intervals")
//            }

        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}




