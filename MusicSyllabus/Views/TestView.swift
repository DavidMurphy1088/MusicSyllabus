import SwiftUI
import CoreData
import AVFoundation
import Accelerate

class ATest {
    
    // Function to perform Fourier Transform on an array of numbers
    func performFourierTransform(input: [Double]) -> [Double] {
        let length = vDSP_Length(input.count)
        let log2n = vDSP_Length(log2(Double(length)))

        // Setup the input/output buffers
        var realPart = [Double](input)
        var imaginaryPart = [Double](repeating: 0.0, count: input.count)
        var splitComplex = DSPDoubleSplitComplex(realp: &realPart, imagp: &imaginaryPart)

        // Create and initialize the FFT setup
        guard let fftSetup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else {
            fatalError("Failed to create FFT setup")
        }

        // Perform the Fourier Transform
        vDSP_fft_zipD(
            fftSetup,
            &splitComplex,
            1,
            log2n,
            FFTDirection(FFT_FORWARD)
        )

        // Release the FFT setup
        vDSP_destroy_fftsetupD(fftSetup)

        return realPart
    }
    
    func convertWavToM4A(inputURL: URL, outputURL: URL?) {
        let asset = AVURLAsset(url: inputURL)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)

        exportSession?.outputFileType = .m4a
        exportSession?.outputURL = outputURL

        exportSession?.exportAsynchronously(completionHandler: {
            switch exportSession?.status {
            case .completed:
                print("Conversion completed successfully.")
            case .failed:
                print("Conversion failed: \(exportSession?.error?.localizedDescription ?? "")")
            case .cancelled:
                print("Conversion cancelled.")
            default:
                break
            }
        })
    }
    
    func segmentWavFile(url: URL, segmentLength: TimeInterval) -> [[Float]]? {
        do {
            let file = try AVAudioFile(forReading: url)
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
            
            let segmentSampleLength = AVAudioFrameCount(segmentLength * file.fileFormat.sampleRate)
            let totalSampleCount = file.length
            let totalSegmentCount = Int(totalSampleCount / Int64(segmentSampleLength))
            
            var segments: [[Float]] = []
            
            for segmentIndex in 0..<totalSegmentCount {
                let startSample = AVAudioFramePosition(segmentIndex) * AVAudioFramePosition(segmentSampleLength)
                let segmentBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: segmentSampleLength)!
                
                try file.read(into: segmentBuffer)
                
                let floatChannelData = segmentBuffer.floatChannelData!
                let channelCount = Int(segmentBuffer.format.channelCount)
                
                var segmentData: [Float] = []
                for frame in 0..<Int(segmentSampleLength) {
                    let sample = floatChannelData.pointee[frame * channelCount]
                    segmentData.append(sample)
                }
                
                segments.append(segmentData)
            }
            
            return segments
        } catch {
            print("Error loading file: \(error.localizedDescription)")
            return nil
        }
    }

    func test() {
//        guard let url = Bundle.main.url(forResource:"simplemelodypiano1", withExtension:".m4a") else {
//            return
//        }
        guard let fileURL = Bundle.main.url(forResource: "simplemelodypiano1", withExtension: "wav") else {
            print("File  not found in the app bundle.")
            return
        }
        //typically 10-50 milliseconds.
        let segmentLength: TimeInterval = 0.002
        
        if let segments = segmentWavFile(url: fileURL, segmentLength: segmentLength) {
            print("Segments", segments.count)
            for segmentIndex in 0..<segments.count {
                let segmentData = segments[segmentIndex]
                let sum = segmentData.reduce(0, +)
                let average = (Double(sum) / Double(segmentData.count)) * 1000
                //print("Segment \(segmentIndex + 1): \(segmentData)")
                if segmentIndex % 10 == 0 {
                    if segmentIndex == 0 {
                        print("Segment Size", segmentData.count)
                    }
                    //print(" time:\t", String(format: "%.2f", Double(segmentIndex) * segmentLength),  "\tAvg:\t", String(format: "%.2f", average))
                    print(String(format: "%.2f", average))
                }
            }
        }

        do {
            let fileData = try Data(contentsOf: fileURL)
            print("total file bytes", fileData.count)
        } catch {
            print("Error loading file: \(error.localizedDescription)")
        }
        let inputSignal = [1.0, 2.0, 3.0, 4.0, 5.0] // Array of numbers
        let result = performFourierTransform(input: inputSignal)
        
        print("Input signal: \(inputSignal)")
        print("Fourier Transform result: \(result)")
    }
}

struct TestView: View {
    var score1:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    var score2:Score = Score(timeSignature: TimeSignature(top: 3,bottom: 4), lines: 1)
    let metronome = Metronome.getMetronomeWithSettings(initialTempo: 40, allowChangeTempo: false)
    let test = ATest()
    
    init () {
        let data = ExampleData.shared
        let exampleData = data.get(contentSection: ContentSection(parent: nil, type: .example, name: "test"))

        let staff1 = Staff(score: score1, type: .treble, staffNum: 0, linesInStaff: 5)
        let staff1B = Staff(score: score1, type: .bass, staffNum: 1, linesInStaff: 5)

        let staff2 = Staff(score: score2, type: .treble, staffNum: 0, linesInStaff: 5)
        
        self.score1.setStaff(num: 0, staff: staff1)
        self.score1.setStaff(num: 1, staff: staff1B)

        self.score2.setStaff(num: 0, staff: staff2)
        
        if let entries = exampleData {
            for entry in entries {
                if entry is Note {
                    let timeSlice = self.score1.addTimeSlice()
                    let note = entry as! Note
                    if note.midiNumber == Note.MIDDLE_C {
                        note.staffNum = 1
                    }
                    note.isOnlyRhythmNote = true
                    timeSlice.addNote(n: note)
                    
//                    var timeSlice2 = self.score2.addTimeSlice()
//                    var n = Note(num:72, value: note.value)
//                    //n.isOnlyRhythmNote = true
//                    timeSlice2.addNote(n: n)

                }
                if entry is TimeSignature {
                    let ts = entry as! TimeSignature
                    score1.timeSignature = ts
                }
                if entry is BarLine {
                    //let bl = entry as! BarLine
                    score1.addBarLine()
                }
                if score1.scoreEntries.count > 200 {
                    break
                }
            }
        }

//        var ts = self.score1.addTimeSlice()
//        ts.addNote(n: Note(num: 48, value: 3.0))
//        ts.addNote(n: Note(num: 52, value: 3.0))
//        ts.addNote(n: Note(num: 55, value: 3.0))

        for i in 0...8 {
            var timeSlice2 = self.score2.addTimeSlice()
            var n = Note(num:67 + (i % 4)*2, value: i % 3 != 0 ? 0.5 : 1.0)
            //n.isOnlyRhythmNote = true
            timeSlice2.addNote(n: n)
        }

      //score1.addStemCharaceteristics()
        //score2.addStemCharaceteristics()
    }
    
    var body: some View {
        //GeometryReader { geometry in
        VStack {
            Text("--Test View--")
            //MetronomeView()
            //ScoreView(score: score1)
//            ScoreView(score: score2)
            
            Text("  ")
            Button(action: {
                test.test()
            }) {
                Text("Test")
            }
        }
            
    }
}

