import SwiftUI
import FirebaseCore
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Logger.logger.log(self, "Firebase Configured")
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        Logger.logger.log(self, "Version.Build \(appVersion).\(buildNumber)")
        return true
    }
    
    //Never appears to be called?
    //App somehow independently does UI to ask permission
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
            if granted {
                Logger.logger.log(self, "Microphone usage granted")
            } else {
                Logger.logger.reportError(self, "Microphone Usage not granted")
            }
        }
    }
    
    static func startAVAudioSession(category: AVAudioSession.Category) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            //Logger.logger.log(self, "Set AVAudioSession category done, category \(category)")
        }
        catch let error {
            Logger.logger.reportError(self, "Set AVAudioSession category failed", error)
        }
    }
}

@main
struct MusicSyllabusApp: App {
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    static let productionMode = true
    //static let root:ContentSection = ContentSection(parent: nil, type: ContentSection.SectionType.none, name: "Musicianship")
    //product licensed by grade 14Jun23
    static let root:ContentSection = ContentSection(parent: nil, type: ContentSection.SectionType.none, name: "Grade 1")
    var launchTimeSecs = 2.5
    
    init() {
        //NoteLayoutPositions.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                
                if launchScreenState.state == .finished {
                    if MusicSyllabusApp.productionMode {
                        TopicsNavigationView(topic: MusicSyllabusApp.root)
                            .tabItem {Label("Exercises", image: "music.note")
                        }
                    }
                    else {
                        IndexView()
                    }
                }
                if MusicSyllabusApp.productionMode {
                    if launchScreenState.state != .finished {
                        LaunchScreenView(launchTimeSecs: launchTimeSecs)
                    }
                }
                
            }
            .environmentObject(launchScreenState)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + launchTimeSecs) {
                    self.launchScreenState.dismiss()
                }
                
            }
        }
    }
}
