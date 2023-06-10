import Foundation
import Accelerate
import AVFoundation

//class AudioAnalyserNew {
//    init() {
//        //var fftSetup = vDSP_DFT_zop_CreateSetup(nil, vDSP_Length(fftSize), vDSP_DFT_Direction.FORWARD)
//    }
//
//    func test() {
//
//
//        // Define the audio file URL
//        let audioURL = Bundle.main.url(forResource: "your_audio_file", withExtension: "mp3")!
//
//        // Set the frame size and overlap percentage
//        let frameSize = 1024
//        let overlapPercentage = 0.5
//
//        // Load the audio file
//        let audioFile = try AVAudioFile(forReading: audioURL)
//        let audioFormat = audioFile.processingFormat
//        let audioFrameCount = UInt32(audioFile.length)
//        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
//        try audioFile.read(into: audioBuffer!)
//
//        // Calculate the frame properties
//        let sampleRate = Float(audioFormat.sampleRate)
//        let frameDuration = Float(frameSize) / sampleRate
//        let overlapSize = Int(Float(frameSize) * overlapPercentage)
//
//        // Calculate Short-Term Energy
//        var energies = [Float]()
//        let buffer = UnsafeBufferPointer(start: audioBuffer.floatChannelData?[0], count: Int(audioFrameCount))
//        for i in stride(from: 0, to: Int(audioFrameCount), by: overlapSize) {
//            let start = i
//            let end = min(i + frameSize, Int(audioFrameCount))
//            
//            var energy: Float = 0
//            for j in start..<end {
//                energy += buffer[j] * buffer[j]
//            }
//            
//            energies.append(energy)
//        }
//
//        // Set the threshold for note detection
//        let threshold: Float = 1000000 // Adjust this value as needed
//
//        // Detect note onsets
//        var noteOnsets = [Float]()
//        for i in 1..<energies.count {
//            let previousEnergy = energies[i-1]
//            let currentEnergy = energies[i]
//            
//            if currentEnergy > threshold && currentEnergy > previousEnergy {
//                let time = Float(i * overlapSize) / sampleRate
//                noteOnsets.append(time)
//            }
//        }
//
//        // Print the detected note onsets
//        for onset in noteOnsets {
//            print("Note onset at time: \(onset)")
//        }
//
//    }
//}
