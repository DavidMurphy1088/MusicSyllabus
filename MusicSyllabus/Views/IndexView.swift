import SwiftUI
import CoreData

struct IndexView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isShowingConfiguration = false

    var body: some View {
        TabView {
            SoundAnalyseView()
                .tabItem {Label("IndexView", systemImage: "music.quarternote.3")}

            TestView()
                .tabItem {Label("Clap_Test", systemImage: "music.quarternote.3")}

            ClapOrPlayView(
                mode: QuestionMode.rhythmVisualClap,
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
                mode: QuestionMode.melodyPlay,
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
    }
}




