import SwiftUI
import CoreData
import AVFoundation

class AudioAnalyser: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, ObservableObject {
    //http://www.mirbsd.org/~tg/soundfont/
    //https://sites.google.com/site/soundfonts4u/
    
    //var sampler:Sampler = Sampler(sf2File: "Metronom")
    
    //var sampler:Sampler = Sampler(sf2File: "gm")
    //var sampler:Sampler = Sampler(sf2File: "PNS Drum Kit")
    //var sampler:Sampler = Sampler(sf2File: "Nice-Steinway-v3.8")
    //var sampler:Sampler = Sampler(sf2File: "Nice-Bass-Plus-Drums-v5.3")
    //var tempo: Double = 1000
    
    var captureSession:AVCaptureSession = AVCaptureSession()
    var captureCtr = 0
    
    static let requiredDecibelChangeInitial = 5 //16
    static let requiredBufSizeInitial = 32
    
    private var requiredDecibelChange = 10
    private var requiredBufSize = 16

    var audioPlayers:[AVAudioPlayer] = []
    
    var decibelBuffer:[DecibelBufferRow] = []
    var logBuffer:[DecibelBufferRow] = []

    var clapCnt = 0
    @Published var clapCounter = 0

    class DecibelBufferRow: Encodable {
        static private var startTime:TimeInterval = 0
        private var ctr:Int
        private var time:TimeInterval
        private var decibelsAvg:Double
        var decibels:Double
        public var clap:Bool

        init(ctr:Int, time:TimeInterval, decibels:Double, decibelsAvg:Double) {
            self.ctr = ctr
            self.time = time
            if ctr == 0 {
                DecibelBufferRow.startTime = time
            }
            self.decibels = decibels
            self.decibelsAvg = decibelsAvg
            self.clap = false
        }
        
        func getRow() -> String {
            var r = "" //String(ctr) + "\t"
            r += String(format: "%.2f", (time - DecibelBufferRow.startTime)) + "\t"
            r += String(decibels + 50.0)
            if clap {
                r += "\t" + String(50.0)
            }
            return r
        }
    }
    
    override init() {
    }
    
    func setRequiredDecibelChange(change:Int) {
        self.requiredDecibelChange = change
        //print("recorder required dec change changed to: \(change)")
    }
    
    func setRequiredBufferSize(change:Int) {
        self.requiredBufSize = change
        self.decibelBuffer = []
        //print("recorder required buffer size change changed to: \(change)")
    }

    func fmt(_ inx:Double) -> String {
        return String(format: "%.4f", inx)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let channel = connection.audioChannels.first else { return }
        //print("audio channel count", connection.audioChannels.count)
        //TODO processBuffer(sampleBuffer: sampleBuffer)
        let decibels = Double(channel.averagePowerLevel)
        //let peak = channel.peakHoldLevel
        //print("AVCaptureOutput - didOutput...", captureCtr, "Decibels", decibels, "buf size", buf.count)

        var sumDecibels = 0.0 //decibelBuffer.reduce(0, +)
        for r in decibelBuffer {
            sumDecibels += r.decibels
        }
        let avgLastDecibels = sumDecibels / Double(decibelBuffer.count)
        
        logBuffer.append(DecibelBufferRow (ctr: captureCtr, time: Date().timeIntervalSince1970, decibels: decibels, decibelsAvg: avgLastDecibels))

        if decibelBuffer.count < requiredBufSize {
            decibelBuffer.append(DecibelBufferRow (ctr: captureCtr, time: Date().timeIntervalSince1970, decibels: decibels, decibelsAvg: avgLastDecibels))
            return
        }
       
        if Int(decibels - avgLastDecibels) > requiredDecibelChange {
            clapCnt += 1
            logBuffer[logBuffer.count-1].clap = true
            DispatchQueue.main.async {
                self.clapCounter += 1
            }
            decibelBuffer = []
            //print(captureCtr, "Claps", clapCnt, "Average", fmt(avgDec), "Dec", fmt(decibels), "buf Size", buf.count)
        }
        else {
            decibelBuffer.append(DecibelBufferRow (ctr: captureCtr, time: Date().timeIntervalSince1970, decibels: decibels, decibelsAvg: avgLastDecibels))
            decibelBuffer.removeFirst()
        }
        captureCtr += 1
    }
    
    func startRecording() {
        self.captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        var audioInput : AVCaptureDeviceInput? = nil
          
        do {
            try captureDevice?.lockForConfiguration()
            audioInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureDevice?.unlockForConfiguration()
        } catch let error {
            Logger.logger.reportError(self, "ClapRecorder:capture", error as NSError)
        }

        // Add audio input
        if captureSession.canAddInput(audioInput!) {
            captureSession.addInput(audioInput!)
        } else {
            Logger.logger.reportError(self, "ClapRecorder:add Input")
        }
        
        //audioOutput = AVCaptureAudioFileOutput()
        let audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "audioQueue"))
        
        if captureSession.canAddOutput(audioOutput) {
            captureSession.addOutput(audioOutput)
        } else {
            Logger.logger.reportError(self, "ClapRecorder:add output")
        }
        captureCtr = 0
        logBuffer = []
        DispatchQueue.global(qos: .background).async {
            //print("Started recording")
            self.captureSession.startRunning()
        }
    }
    
    func displayLogBuffer() {
        var c = 0
        for row in logBuffer {
            print(row.getRow())
            c += 1
//            if c > 400 {
//                break
//            }
        }
        //FirestorePersistance.shared.saveClaps(data: decibelBuffer)
    }
    
    func stopRecording() {
        DispatchQueue.global(qos: .background).async {
            print("Stopped recording")
            self.captureSession.stopRunning()
            self.displayLogBuffer()
        }
    }
}
