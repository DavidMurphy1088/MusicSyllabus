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
    @State private var imageOpacity: Double = 0
    static var durationSeconds = 3.0
    @State var ctr = 0.0
    
    @ViewBuilder
    
    private var image: some View {  // Mark 3
        GeometryReader { geo in
            VStack {
                Spacer()
                //Image(systemName: "hurricane")
                HStack {
                    Spacer()
                    Image("nzmeb_logo_transparent")
                        .resizable()
                        .scaledToFit()
                    //.frame(width: 200, height: 200)
                        .frame(width: geo.size.width * 0.75)
                    //.rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800)) // Mark 4
                    //.scaleEffect(secondAnimation ? 0 : 1) // Mark 4
                    //.offset(y: secondAnimation ? 400 : 0) // Mark 4
                        .opacity(imageOpacity)
                        //.border(Color(.red))
                    Spacer()
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
        //Color.orange.ignoresSafeArea()
        //Color.cyan.ignoresSafeArea()
        Color.teal.ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.07, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }
        .onReceive(animationTimer) { timerValue in
            //updateAnimation()  // Mark 5
            ctr += 1
            imageOpacity = sin(Double(ctr / (LaunchScreenView.durationSeconds * Double.pi * 2.0)))
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


