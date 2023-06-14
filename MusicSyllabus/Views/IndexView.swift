import SwiftUI
import CoreData

struct IndexView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isShowingConfiguration = false

    var body: some View {
        TabView {
            if !MusicSyllabusApp.productionMode {
                SoundAnalyseView() 
                
                ClapOrPlayView(
                    mode: QuestionMode.rhythmClap,
                    contentSection: ContentSection(parent: nil,
                                                   type: ContentSection.SectionType.testType,
                                                   name: "test_clap")
                )
                .tabItem {Label("Clap_Test", systemImage: "music.quarternote.3")
                }

                IntervalView(
                    mode: QuestionMode.intervalAural,
                    contentSection: ContentSection(parent: nil,
                                                   type: ContentSection.SectionType.testType,
                                                   name: "test_aural_interval")
                )
                .tabItem {Label("AuralInt", systemImage: "music.quarternote.3")
                }

                
                
                ClapOrPlayView(
                    mode: QuestionMode.rhythmPlay,
                    contentSection: ContentSection(parent: nil,
                                                   type: ContentSection.SectionType.testType,
                                                   name: "test_clap")
                )
                .tabItem {Label("Play_Test", systemImage: "music.quarternote.3")
                }


                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Musicianship1", systemImage: "music.note.list")
                    }
                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Musicianship2", systemImage: "music.note.list")
                    }

            }
            else {
                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Exercises", image: "music.note")}
                ConfigurationView(isPresented: $isShowingConfiguration)
                    .tabItem {Label("Configuration", image: "music.note")}
            }
            //.navigationViewStyle(StackNavigationViewStyle())
            }
        }
}




