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
            //try? await Task.sleep(for: Duration.seconds(1))
            sleep(1)
            self.state = .finished
        }
    }
}

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1

    @State private var firstAnimation = false  // Mark 2
    @State private var secondAnimation = false // Mark 2
    @State private var startFadeoutAnimation = false // Mark 2
    @State private var imageOpacity: Double = 0
    static var durationSeconds = 3.0
    @State var ctr = 0.0
    @State var inc = 1.0
    
    @ViewBuilder
    
    private var image: some View {  // Mark 3
        GeometryReader { geo in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image("nzmeb_logo_transparent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width * 0.75)
                            .opacity(imageOpacity)
                        //.border(Color(.red))
                        Spacer()
                    }
                    Spacer()
                }
                VStack(alignment: .center) {
                    Text("NZMEB Musicianship Trainer")
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.85)
                        //.font(.title)
                        .opacity(imageOpacity)
                }
            }
        }
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
        //Color.orange.ignoresSafeArea()
        //Color.cyan.ignoresSafeArea()
        //Color.gray.ignoresSafeArea()
        //Color.blue.ignoresSafeArea()
        //Color.secondary.ignoresSafeArea()
        Color(red: 150 / 255, green: 210 / 255, blue: 225 / 255).ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.05, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }
        .onReceive(animationTimer) { timerValue in
            //updateAnimation()  // Mark 5
            ctr += inc
            imageOpacity = sin(Double(ctr / (LaunchScreenView.durationSeconds * Double.pi * 2.0)))
//            if imageOpacity > 0.96 {
//                inc += 0.25
//            }
        }
        //.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
//    private func updateAnimation() { // Mark 5
//        switch launchScreenState.state {
//        case .firstStep:
//            withAnimation(.easeInOut(duration: 0.9)) {
//                firstAnimation.toggle()
//            }
//        case .secondStep:
//            if secondAnimation == false {
//                withAnimation(.linear) {
//                    self.secondAnimation = true
//                    startFadeoutAnimation = true
//                }
//            }
//        case .finished:
//            // use this case to finish any work needed
//            break
//        }
//    }
    
}

//struct LaunchScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchScreenView()
//            .environmentObject(LaunchScreenStateManager())
//    }
//}


