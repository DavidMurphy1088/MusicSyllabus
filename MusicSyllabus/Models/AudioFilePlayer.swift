import SwiftUI
import CoreData
import AVFoundation

class AudioFilePlayer: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer: AVAudioPlayer?
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func playFile() {
        // Set up the audio player with the recorded audio file
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error initializing audio player: \(error)")
        }
        
        // Check if the audio player is initialized
        guard let player = audioPlayer else {
            print("Audio player not initialized")
            return
        }
        
        // Play the recorded audio file
        if !player.isPlaying {
            player.play()
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio playback finished successfully")
        } else {
            print("Audio playback finished with an error")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio playback error: \(error)")
        }
    }
}
