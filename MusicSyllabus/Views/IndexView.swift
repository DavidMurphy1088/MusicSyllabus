import SwiftUI
import CoreData

struct IndexView: View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            if !MusicSyllabusApp.productionMode {
                
                
                ClapOrPlayView(
                    mode: QuestionMode.clap,
                    contentSection: ContentSection(parent: nil,
                                                   type: ContentSection.SectionType.testType,
                                                   name: "test_clap")
                )
                .tabItem {Label("Clap_Test", systemImage: "music.quarternote.3")
                }
                
                ClapOrPlayView(
                    mode: QuestionMode.play,
                    contentSection: ContentSection(parent: nil,
                                                   type: ContentSection.SectionType.testType,
                                                   name: "test_clap")
                )
                .tabItem {Label("Play_Test", systemImage: "music.quarternote.3")
                }

//                
//                IntervalView(
//                    //                    presentType: IntervalPresentView.self,
//                    //                    answerType: IntervalAnswerView.self,
//                    contentSection: ContentSection(parent: nil,
//                                                   type: ContentSection.SectionType.testType,
//                                                   name: "test_interval")
//                )
//                .tabItem {Label("Playing", systemImage: "music.quarternote.3")
//                }
//
                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Musicianship1", systemImage: "music.note.list")
                    }
                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Musicianship2", systemImage: "music.note.list")
                    }

            }
            else {
                TopicsNavigationView(topic: MusicSyllabusApp.root)
                    .tabItem {Label("Exercises", image: "music.note")
                    }
                ConfigurationView()
                    .tabItem {Label("Configuration", image: "music.note")
                    }
                //                TopicsNavigationView(topic: root)
                //                    .tabItem {Label("Book3", image: "music.note")
                //                }
            }
            //.navigationViewStyle(StackNavigationViewStyle())
            }
            //.accentColor(.blue)
            
        }

}




