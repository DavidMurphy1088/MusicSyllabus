import Foundation
import Accelerate
import AVFoundation

enum TickType {
    case metronome
    case handclap
}

class AudioPlayer {
    private var midiSampler:AVAudioUnitSampler?
    private var audioPlayers:[AVAudioPlayer] = []
    private var numAudioPlayers = 16
    private var nextPlayer = 0
    
    
    init(tickType:TickType) {
        let fileName:String
        let clapURL:URL?
        if tickType == .metronome {
            fileName = "Mechanical metronome - High"
            clapURL = Bundle.main.url(forResource: fileName, withExtension: "aif")
        }
        else {
            fileName = "404543__inspectorj__clap-single-16"
            clapURL = Bundle.main.url(forResource: fileName, withExtension: "wav")
        }

        if clapURL == nil {
            Logger.logger.reportError(self, "Cannot load resource \(fileName)")
        }
        for _ in 0..<numAudioPlayers {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: clapURL!)
                //if audioPlayer != nil {
                    audioPlayers.append(audioPlayer)
                    audioPlayer.prepareToPlay()
                    audioPlayer.volume = 1.0 // Set the volume to full
                    audioPlayer.rate = 2.0
                //}
            }
            catch  {
                Logger.logger.reportError(self, "Cannot prepare AVAudioPlayer")
            }
        }
    }
    
    func play() {
        self.audioPlayers[nextPlayer].play()
        nextPlayer += 1
        if nextPlayer > numAudioPlayers - 1 {
            nextPlayer = 0
        }
    }
}
