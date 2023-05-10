import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      Logger.logger.log("Firebase Configured")
      Metronome.initialize()
      return true
  }
}

@main
struct MusicSyllabusApp: App {
    let persistenceController = PersistenceController.shared
    //register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            TopView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
