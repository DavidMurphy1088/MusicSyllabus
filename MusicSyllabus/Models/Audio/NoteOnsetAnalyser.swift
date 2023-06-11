import Foundation
import SwiftUI
import CoreData
import AVFoundation
import Accelerate

class NoteOnsetAnalyser : ObservableObject {
    @Published var segmentAverages:[Double] = []
    @Published var fourierValues:[Double] = []
    @Published var fourierTransformValues:[Double] = []
    @Published var sampleTime:Double = 0.0
    @Published var status:String = ""
    var framesPerSegment:Int = 0
    var audioFile:AVAudioFile?
    var frameValues:[Double] = []
    
    func setTimeSlice() {
        DispatchQueue.main.async {
            self.sampleTime = 1000.0 / self.sampleTime
        }
    }
    
    func setStatus(_ msg:String) {
        print("NoteOnsetAnalyser \(msg)")
        DispatchQueue.main.async {
            self.status = self.status
        }
    }
    
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
        
    //segment a sound recordings into segments of specified length time
    func segmentWavFile(url:URL, segmentLengthSecondsMilliSec: TimeInterval) -> [[Double]]? {
        do {
            var audioFile = try AVAudioFile(forReading: url)
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: audioFile.fileFormat.sampleRate,
                                       channels: audioFile.fileFormat.channelCount, interleaved: false)
            
            framesPerSegment = Int(AVAudioFrameCount(segmentLengthSecondsMilliSec * audioFile.fileFormat.sampleRate / 1000.0))
            let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
            
            let audioFileLength = audioFile.length
            let totalSegmentCount = Int(audioFileLength / Int64(framesPerSegment))
            self.setStatus("segmentWavFile::start")
            print ("segmentWavFile::",
                   "\n  audioDuration:", duration,
                   "\n  samplesPerSegment:", framesPerSegment,
                   "\n  segment count:", totalSegmentCount,
                   "\n  segmentLengthSeconds ms:", segmentLengthSecondsMilliSec,
                   "\n  sample rate per sec:", audioFile.fileFormat.sampleRate)
            
            //read the whole file to gte average and maximum
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            var maxValue:Double = 0.0

            if let audioBuffer = audioBuffer {
                try audioFile.read(into: audioBuffer)
                if let floatChannelData = audioBuffer.floatChannelData {
                    let channelCount = Int(audioFile.processingFormat.channelCount)
                    let frameLength = Int(audioBuffer.frameLength)
                    var ctr = 0
                    var totalValue:Double = 0.0
                    // Iterate over the audio frames and access the sample values
                    for frame in 0..<frameLength {
                        for channel in 0..<channelCount {
                            let sampleValue = Double(floatChannelData[channel][frame])
                            if Double(sampleValue) > maxValue {
                                maxValue = Double(sampleValue)
                            }
                            totalValue += sampleValue
                            ctr += 1
                        }
                    }
                    print ("totalFrames:", frameLength, "maxValue:", maxValue, "AvgValue:", totalValue / Double(frameLength))
                }
            }
        
             // make the segments
            audioFile = try AVAudioFile(forReading: url) //required since the scan of the whole file above makes this next code fail
            var segments: [[Double]] = []
            let threshold = maxValue * 0.2
            var frameCtr = 0
            
            for segmentIndex in 0..<totalSegmentCount {
                let startSample = AVAudioFramePosition(segmentIndex) * AVAudioFramePosition(framesPerSegment)
                let segmentBuffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(framesPerSegment))!
                
                try audioFile.read(into: segmentBuffer)
                let floatChannelData = segmentBuffer.floatChannelData!
                let channelCount = Int(segmentBuffer.format.channelCount)
                
                var segmentData: [Double] = []
                for frame in 0..<Int(framesPerSegment) {
                    let sample = Double(floatChannelData.pointee[frame * channelCount])
                    if abs(sample) > threshold {
                        segmentData.append(sample)
                    }
                    else {
                        segmentData.append(0.0)
                    }
                    self.frameValues.append(sample)
                }
                segments.append(segmentData)
            }
            self.setStatus("segmentWavFile::end")
            return segments
        } catch {
            print("Error loading file: \(error.localizedDescription)")
            return nil
        }
    }

    func subArray(array:[Double], at:Int, fwd: Bool, len:Int) -> [Double] {
        var res:[Double] = []
        let sign = 1.0 //array[at] < 0.0 ? -1.0 : 1.0
        if fwd {
            if at + len >= array.count - 1 {
                return res
            }
            let to = at+len
            for i in at..<to {
                res.append(array[i] * array[i] * sign)
            }
        }
        else {
            if at - len < 0 {
                return res
            }
            let from = at-len
            for i in from..<at {
                res.append(array[i] * array[i] * sign)
            }
        }
        return res
    }
    
    class NoteOffset {
        var startSegment:Int
        var endSegment:Int
        init(startSegment:Int, endSegment:Int) {
            self.startSegment = startSegment
            self.endSegment = endSegment
        }
        func duration() -> Double {
            return Double(endSegment - startSegment)
        }
    }
    
    func extractPitchFromFFTResult(_ fftResult: [Float], sampleRate: Float) -> Double? {
        let fftSize = vDSP_Length(fftResult.count)
        
        // Find the index with the maximum amplitude
        var maxAmplitude: Float = 0
        var maxAmplitudeIndex: vDSP_Length = 0
        vDSP_maxvi(fftResult, 1, &maxAmplitude, &maxAmplitudeIndex, fftSize)
        
        // Calculate the corresponding frequency bin
        let binFrequency = sampleRate / Float(fftSize)
        let dominantFrequency = Double(maxAmplitudeIndex) * Double(binFrequency)
        
        // Convert frequency to pitch (in MIDI note number)
        let pitch = 69 + 12 * log2(dominantFrequency / 440)
        
        return pitch
    }
    
    func detectNotes(segmentAverages:[Double], noteOnsetSliceWidthPercent:Double, segmentLengthSecondsMilliSec: Double, FFTWindowSize:Int) {
        var result:[NoteOffset] = []
        
        //var sliceLengtho = Int(Double(segmentAverages.count) / 200.0)
        var sliceLength = Int(Double(segmentAverages.count) * noteOnsetSliceWidthPercent)
        print("\ndetectNotes::",
              "\n  segmentsCount:", segmentAverages.count,
              "\n  SliceWidthPercent", noteOnsetSliceWidthPercent,
              "\n  sliceLength:", sliceLength,
              "\n  segmentLengthSecondsMilliSec:", segmentLengthSecondsMilliSec,
              "\n  MaxSegAvg:", segmentAverages.max() ?? 0)
        let maxAmplitude = segmentAverages.max() ?? 0
        let threshold = maxAmplitude * 0.015
        var notesCount = 0
        
        var noteOffsets:[(Int, Double)] = []
        var lastNoteIdx:Int?
        
        var segmentIdx = sliceLength
        while segmentIdx < segmentAverages.count {
            let prev = subArray(array: segmentAverages, at: segmentIdx, fwd:false, len: sliceLength)
            let next = subArray(array: segmentAverages, at: segmentIdx, fwd:true, len: sliceLength)
//            if prev.count < sliceLength || next.count < sliceLength {
//                continue
//            }
            let prevAvg = prev.reduce(0, +) /// Double(prev.count)
            let nextAvg = next.reduce(0, +) /// Double(prev.count)
            if nextAvg - prevAvg > threshold {
                let time = Double(segmentIdx) * segmentLengthSecondsMilliSec / 1000.0
                //print("Notes:", notesCount, "time:", String(format: "%.2f", time))
                
                //save the note location and value
                if let lastNoteIdx = lastNoteIdx {
                    let lastNoteOffset = NoteOffset(startSegment: lastNoteIdx, endSegment: segmentIdx)
                    result.append(lastNoteOffset)
                }
                
                notesCount += 1
                lastNoteIdx = segmentIdx
                
                //jump ahead to next note, assume shortest note is value 1/4 of 1.0
                let segmentsPerSec = 1000.0 / segmentLengthSecondsMilliSec
                segmentIdx += Int(segmentsPerSec / 4.0)
            }
            else {
                segmentIdx += sliceLength
            }
        }
        
        //show the notes and calculate the fourier for each note's range of frame indexes
        let firstNoteDuration = result[0].duration()
        var pitches:[Double] = []
        
        for i in 0..<result.count {
            let offset = result[i]
            var frameValues:[Double] = []
            var startFrame = offset.startSegment * self.framesPerSegment
            //startFrame += 2000 //----?? on waveform first part looks noisy
            let endFrame = startFrame + Int(offset.duration()) * self.framesPerSegment
            var ctr = 0
            for j in startFrame...endFrame {
                //segmentValues.append(segmentAverages[j])
                frameValues.append(self.frameValues[j])
                if ctr > FFTWindowSize {
                    break
                }
                ctr += 1
            }
            //let nonZeroCount = segmentValues.filter { $0 != 0.0 }.count
            let fourierTransformValues = self.performFourierTransform(input: frameValues)
            var floats:[Float] = []
            for ft in fourierTransformValues {
                floats.append(Float(ft))
            }
            let pitch = extractPitchFromFFTResult(floats, sampleRate: 44100.0)
            //print (res)
//            let sum = fourierTransformValues.reduce(0, +)
//            let average = sum / Double(fourierTransformValues.count)
//            var maxX = 0
//            var maxVal = 0.0
//            for i in 0..<fourierTransformValues.count {
//                if fourierTransformValues[i] > maxVal {
//                    maxVal = fourierTransformValues[i]
//                    maxX = i
//                }
//            }
            print("Note", i,
                  "Value:", String(format: "%.2f", offset.duration() / firstNoteDuration),
                  "\n  SegmentsDuration:", offset.duration(),
//                  "\n  StartSegment:", offset.startSegment,
//                  "\n  EndSegment:", offset.startSegment + Int(offset.duration()),
                  "\n  Frames:", endFrame - startFrame,
                  "\n  FourierInCount:", frameValues.count
                  //"\n  Pitch:", pitch ?? 0
            )
            pitches.append(pitch ?? 0)
            //print("  Fourier", average, f.count)
            if i == 5 {
                DispatchQueue.main.async {
                    self.fourierValues = []
                    self.fourierTransformValues = []
                    for f in frameValues {
                        self.fourierValues.append(f)
                    }
                    for f in fourierTransformValues {
                        self.fourierTransformValues.append(f)
                    }
                }
            }
            
        }
        
        for i in 0..<result.count {
            let value = result[i].duration() / firstNoteDuration
            print("\(i) " + String(format: "%.1f", value) + " " + String(format: "%.0f", pitches[i]))
        }

    }
    
    func getSine(elements:Int, period:Double) -> [Double] {
        var res:[Double] = []
        //let p = 2.0 * Double.pi // Period of the sine wave
        let p = period * Double.pi // Period of the sine wave
        for i in 0..<elements {
            let x = Double(i) * (p / Double(elements - 1))
            let sineValue = sin(x)
            res.append(sineValue)
        }
        return res
    }
    
    func fourier() {
        let numberOfElements = 1000
        let sineArray1 = getSine(elements: numberOfElements, period: 50.0)
        let sineArray2 = getSine(elements: numberOfElements, period: 31.0)
        let sineArray3 = getSine(elements: numberOfElements, period: 77.0)

        var sumArray: [Double] = []
        for i in 0..<numberOfElements {
            let sum = sineArray1[i] + sineArray2[i]// + sineArray3[i]
            sumArray.append(sum)
        }

        let fourier = self.performFourierTransform(input: sumArray)
        let fMax = fourier.max()
        print("Fourier len:", fourier.count, "Max:", fMax ?? 0)
        var ctr = 0
        for f in fourier {
            if f > fMax! * 0.5 {
                print("index", ctr, "value", f)
            }
            ctr += 1
        }
        
        DispatchQueue.main.async {
            self.fourierValues = []
            self.fourierTransformValues = []
            for s in sumArray {
                self.fourierValues.append(s)
            }
            for f in fourier {
                self.fourierTransformValues.append(f)
            }
        }
    }
    
    func processFile(fileName:String, segmentLengthSecondsMilliSec: Double) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            print("File  not found in the app bundle.")
            return
        }
        
        //typically 10-50 milliseconds.
        var avgs:[Double] = []

        //Collapse the segment frame values to an average per segment
        if let segments = segmentWavFile(url: url,
                                         segmentLengthSecondsMilliSec: segmentLengthSecondsMilliSec) {
            for segmentIndex in 0..<segments.count {
                let segmentData = segments[segmentIndex]
                let sum = segmentData.reduce(0, +)
                let average = (Double(sum) / Double(segmentData.count)) * 1000
                avgs.append(average)
             }
        }

//        let inputSignal = [1.0, 2.0, 3.0, 4.0, 5.0] // Array of numbers
//        let result = performFourierTransform(input: inputSignal)
//
//        print("Input signal: \(inputSignal)")
//        print("Fourier Transform result: \(result)")
        
        DispatchQueue.main.async {
            self.segmentAverages = []
            for i in 0..<avgs.count {
                self.segmentAverages.append(avgs[i] / 1.0)
                self.sampleTime = segmentLengthSecondsMilliSec //1.0 / sampleTimeDivisor
            }
        }
    }
}

//    func convertWavToM4A(inputURL: URL, outputURL: URL?) {
//        let asset = AVURLAsset(url: inputURL)
//        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
//
//        exportSession?.outputFileType = .m4a
//        exportSession?.outputURL = outputURL
//
//        exportSession?.exportAsynchronously(completionHandler: {
//            switch exportSession?.status {
//            case .completed:
//                print("Conversion completed successfully.")
//            case .failed:
//                print("Conversion failed: \(exportSession?.error?.localizedDescription ?? "")")
//            case .cancelled:
//                print("Conversion cancelled.")
//            default:
//                break
//            }
//        })
//    }
