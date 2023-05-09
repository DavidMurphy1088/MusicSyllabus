import SwiftUI
import CoreData

struct TopView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            RhythmsView(exampleNum: 0, questionData: "72,67")
            .tabItem {
                Label("Rhythm", systemImage: "music.note")
            }

            ClapTestView()
            .tabItem {
                Label("ClapTest", systemImage: "music.note")
            }


            IntervalsView(exampleNum: 0, questionData: "72,67")
            .tabItem {
                Label("Intervals", systemImage: "music.note")
            }
            
            TopicsViewNavigation(topic: Topic(parent: nil, level: 0, number: 0, name: "Grades"))
            .tabItem {
                Label("Topics", image: "triads")
            }

        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}




