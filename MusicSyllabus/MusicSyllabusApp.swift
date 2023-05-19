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
            //try AVAudioSession.sharedInstance().setActive(false)
            try AVAudioSession.sharedInstance().setCategory(category, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            Logger.logger.log(self, "Set AVAudioSession category done, category \(category)")
            //let perms = AVAudioSession.sharedInstance().recordPermission
            //Logger.logger.log(self, "AVAudioSession permission \(perms.rawValue)")
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                print("App Version: \(appVersion)")
            }
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
    static let devMode = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if !MusicSyllabusApp.devMode {
                    if launchScreenState.state != .finished {
                        LaunchScreenView()
                    }
                }
            }.environmentObject(launchScreenState)
        }
    }
}

struct ContentView: View {
    //https://holyswift.app/animated-launch-screen-in-swiftui/
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        VStack {
            IndexView() //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .padding()
        .task {
            //try? await getDataFromApi()
            try? await Task.sleep(for: Duration.seconds(3))
            self.launchScreenState.dismiss()
        }
    }
    
    fileprivate func getDataFromApi() async throws {
        let googleURL = URL(string: "https://www.google.com")!
        let (_,response) = try await URLSession.shared.data(from: googleURL)
        print(response as? HTTPURLResponse)
    }
}
