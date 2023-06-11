//import AVFoundation
//import AudioKit
//
//class Fourier {
//
//
//    func RhythmAndPitch()  {
//        do {
//            guard let audioFileURL = Bundle.main.url(forResource: "Example 1", withExtension: "wav") else {
//                print("File  not found in the app bundle.")
//                return
//            }
//
//            //let audioFileURL = URL(fileURLWithPath: "path_to_your_audio_file")
//            
//            // Create AVAudioFile
//            //let audioFile = try AVAudioFile(forReading: audioFileURL)
//
//            //let audioFileURL = URL(fileURLWithPath: "path_to_your_audio_file")
//
//            // Create AVAudioFile
//            let audioFile = try AVAudioFile(forReading: audioFileURL)
//
//            // Create AVAudioEngine
//            let audioEngine = AVAudioEngine()
//
//            // Create AVAudioPlayerNode
//            let audioPlayerNode = AVAudioPlayerNode()
//            audioEngine.attach(audioPlayerNode)
//
//            // Connect player node to engine's main mixer
//            let mixer = audioEngine.mainMixerNode
//            audioEngine.connect(audioPlayerNode, to: mixer, format: audioFile.processingFormat)
//
//            // Start the audio engine
//            try audioEngine.start()
//
//            // Define silence threshold (adjust as needed)
//            let silenceThreshold: Float = -60.0
//
//            // Define minimum note duration (adjust as needed)
//            let minimumNoteDuration: Double = 0.1
//
//            // Initialize the note start time, duration, and pitch arrays
//            var noteStartTimes: [Double] = []
//            var noteDurations: [Double] = []
//            var notePitches: [Double] = []
//
//            // Analyze the audio file to determine note start times, durations, and pitches
//            var framePosition = AVAudioFramePosition(0)
//
//            audioPlayerNode.scheduleSegment(audioFile,
//                                            startingFrame: framePosition,
//                                            frameCount: AVAudioFrameCount(audioFile.length - framePosition),
//                                            at: nil,
//                                            completionCallbackType: .dataPlayedBack,
//                                            completionHandler: { (callbackType) in
//                                                if callbackType == .dataPlayedBack {
//                                                    // Stop the audio engine when playback is finished
//                                                    audioEngine.stop()
//                                                }
//                                            })
//
//            // Start the audio player node
//            audioPlayerNode.play()
//
//            var ctr = 0
//            while audioEngine.isRunning {
//                // Read the current frame position
//                if let lastRenderTime = audioPlayerNode.lastRenderTime,
//                   let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
//                    framePosition = playerTime.sampleTime
//                }
//
//                // Create an AVAudioPCMBuffer to hold the audio data
//                let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(1024))
//                
//                // Read audio data into the buffer
//                try audioFile.read(into: buffer!)
//                
//                // Analyze the audio data
//                let analysisResult = analyzeAudioBuffer(buffer!)
//                
//                // Check if the audio is above the silence threshold
//                if analysisResult.averagePower > silenceThreshold {
//                    // Calculate the time stamp of the current frame
//                    let currentTime = Double(framePosition) / audioFile.processingFormat.sampleRate
//                    
//                    // Check if this is the start of a new note
//                    if noteStartTimes.isEmpty || currentTime - noteStartTimes.last! > minimumNoteDuration {
//                        noteStartTimes.append(currentTime)
//                        noteDurations.append(0)
//                        notePitches.append(analysisResult.pitch)
//                    }
//                    
//                    // Increment the duration of the current note
//                    noteDurations[noteDurations.count - 1] += Double(buffer!.frameLength) / audioFile.processingFormat.sampleRate
//                }
//                if ctr % 10 == 0 {
//                    print(ctr)
//                }
//                ctr += 1
//
//            }
//
//            // Print the note information
//            for i in 0..<noteStartTimes.count {
//                print("Note \(i + 1):")
//                print("Start Time: \(noteStartTimes[i]) seconds")
//                print("Duration: \(noteDurations[i]) seconds")
//                print("Pitch: \(notePitches[i])")
//                print("--------------")
//            }
//
//            // Function to analyze the audio buffer and calculate the average power
//            // and pitch (replace with your own implementation)
//            func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer) -> (averagePower: Float, pitch: Double) {
//                // Convert the buffer to an AKBuffer for AudioKit processing
//                let audioPlayer = try? AKAudioPlayer(buffer: buffer)
//
//                    // Create an AKPitchTap to analyze the audio input
//                    let pitchTap = AKPitchTap(audioPlayer)
//
//                    // Start the audio player
//                    audioPlayer?.play()
//
//                    // Wait for the audio player to finish playing
//                    while audioPlayer?.isPlaying ?? false {}
//
//                    // Stop AudioKit
//                    AudioKit.stop()
//
//                    // Get the average power and pitches from the pitch tap
//                    let averagePower = audioPlayer?.rms ?? 0.0
//                    let pitches = pitchTap.pitchData.map { $0.pitch }
//
//                    return (averagePower, pitches)            }
//
//        }
//        catch {
//            print (error.localizedDescription)
//        }
//
//    }
//        
//}
//
