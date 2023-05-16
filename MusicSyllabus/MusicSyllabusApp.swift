import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      Logger.logger.log(self, "Firebase Configured")
      //Metronome.initialize()
      return true
  }
}

//@main
//struct MusicSyllabusApp: App {
//    let persistenceController = PersistenceController.shared
//    //register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//    @StateObject var launchScreenState = LaunchScreenStateManager()
//
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
//                TopView().environment(\.managedObjectContext, persistenceController.container.viewContext)
//                if launchScreenState.state != .finished {
//                    LaunchScreenView()
//                }
//            }
//            .environmentObject(launchScreenState)
//        }
//    }
//}


@main
struct MusicSyllabusApp: App {

    @StateObject var launchScreenState = LaunchScreenStateManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if launchScreenState.state != .finished {
                    LaunchScreenView()
                }
            }.environmentObject(launchScreenState)
        }
    }
}
