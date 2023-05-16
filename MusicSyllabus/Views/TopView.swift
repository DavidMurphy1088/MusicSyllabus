import SwiftUI
import CoreData

struct TopView: View {
    @Environment(\.scenePhase) var scenePhase
    let root = ContentSection(parent: nil, type: ContentSection.SectionType.none, name: "NZMEB Musicianship")
    static let devMode = true
    
    init () {
//        if devMode {
//           // Metronome.shared.setTempo(tempo: 120)
//        }
    }
        
    var body: some View {
        TabView {
            if TopView.devMode {
                
                TopicsViewNavigation(topic: root)
                    .tabItem {Label("Book1", image: "music.note")
                }
                
                ClapOrPlay(mode: .play, contentSection:
                    ContentSection(parent: ContentSection(parent: nil,type: ContentSection.SectionType.none, name: "Playing"),
                    type: ContentSection.SectionType.example, name: "test"))
                    .tabItem {Label("Playing", systemImage: "music.quarternote.3")
                }


                ClapOrPlay(mode: .clap, contentSection:
                    ContentSection(parent: ContentSection(parent: nil,type: ContentSection.SectionType.none, name: "Clapping"),
                    type: ContentSection.SectionType.example, name: "test"))
                    .tabItem {Label("Clapping", systemImage: "hands.clap")
                }

                IntervalsView(contentSection:
                    ContentSection(parent: ContentSection(parent: nil,type: ContentSection.SectionType.none, name: "Intervals Visual"),
                    type: ContentSection.SectionType.example, name: "test"))
                    .tabItem {Label("Intervals", systemImage: "music.note.list")
                }

//                
//                ClapTestView()
//                    .tabItem {Label("ClapTest", systemImage: "music.note")
//                }
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
        .accentColor(.blue)
    }
    
}




