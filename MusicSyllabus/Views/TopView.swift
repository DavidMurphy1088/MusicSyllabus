import SwiftUI
import CoreData

struct TopView: View {
    @Environment(\.scenePhase) var scenePhase
    let root = ContentSection(parent: nil, type: ContentSection.SectionType.none, name: "")
    let devMode = true
    
    init () {
        if devMode {
            Metronome.shared.setTempo(tempo: 120)
        }
        
    }
    var body: some View {
        TabView {
            if devMode {
                IntervalsView(contentSection: ContentSection(parent: nil, type: ContentSection.SectionType.example, name: "test"))
                    .tabItem {Label("Intervals", systemImage: "music.note")
                }
                RhythmsView(contentSection: ContentSection(parent: nil, type: ContentSection.SectionType.example, name: "TestClap"))
                    .tabItem {Label("Clapping", systemImage: "music.note")
                }
                TopicsViewNavigation(topic: root)
                    .tabItem {Label("Book1", image: "music.note")
                }
                //            ClapTestView()
                //            .tabItem {
                //                Label("ClapTest", systemImage: "music.note")
                //            }
            }
            else {
                TopicsViewNavigation(topic: root)
                    .tabItem {Label("Book1", image: "music.note")
                }
                TopicsViewNavigation(topic: root)
                    .tabItem {Label("Book2", image: "music.note")
                }
                TopicsViewNavigation(topic: root)
                    .tabItem {Label("Book3", image: "music.note")
                }
            }
            //.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}




