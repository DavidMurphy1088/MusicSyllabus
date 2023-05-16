import Foundation
import SwiftUI

enum LaunchScreenStep {
    case firstStep
    case secondStep
    case finished
}

final class LaunchScreenStateManager: ObservableObject {

@MainActor @Published private(set) var state: LaunchScreenStep = .firstStep
    @MainActor func dismiss() {
        Task {
            state = .secondStep
            try? await Task.sleep(for: Duration.seconds(1))
            self.state = .finished
        }
    }
}

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1

    @State private var firstAnimation = false  // Mark 2
    @State private var secondAnimation = false // Mark 2
    @State private var startFadeoutAnimation = false // Mark 2
    
    @State private var imageOpacity: Double = 0.05

    @ViewBuilder
    private var image: some View {  // Mark 3
        //Image(systemName: "hurricane")
        Image("nzbeb-bird")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            //.rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800)) // Mark 4
            //.scaleEffect(secondAnimation ? 0 : 1) // Mark 4
            //.offset(y: secondAnimation ? 400 : 0) // Mark 4
            .opacity(imageOpacity)
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
        //Color.orange.ignoresSafeArea()
        //Color.cyan.ignoresSafeArea()
        Color.teal.ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        //.publish(every: 0.5, on: .current, in: .common)
        .publish(every: 0.05, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }.onReceive(animationTimer) { timerValue in
            //updateAnimation()  // Mark 5
            imageOpacity *= 1.05
        }
        //.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
    private func updateAnimation() { // Mark 5
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if secondAnimation == false {
                withAnimation(.linear) {
                    self.secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            // use this case to finish any work needed
            break
        }
    }
    
}

//struct LaunchScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchScreenView()
//            .environmentObject(LaunchScreenStateManager())
//    }
//}


struct ContentView: View {
    //https://holyswift.app/animated-launch-screen-in-swiftui/
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        VStack {
//            Image(systemName: "applescript")
//                .resizable()
//                .scaledToFit()
//                .foregroundColor(.accentColor)
//                .frame(width: 150, height: 150)
            //Text("Hello, Apple Script!").font(.largeTitle)
            TopView() //.environment(\.managedObjectContext, persistenceController.container.viewContext)
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(LaunchScreenStateManager())
//    }
//}
