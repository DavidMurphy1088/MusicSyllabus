import SwiftUI
import CoreData

struct TopView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            IntervalsView(exampleNum: 0)
            .tabItem {
                Label("Clapping", systemImage: "music.note")
            }

            ClappingView(exampleNum: 0)
            .tabItem {
                Label("Clapping", systemImage: "music.note")
            }
            
            TopicsViewNavigation(topic: Topic(parent: nil, level: 0, number: 0, name: "Grades"))
            .tabItem {
                Label("Topics", image: "triads")
            }

        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}




