//
//  ContentView.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//
import SwiftUI //
import WatchKit
import AVFoundation


struct ContentView: View {
    @State private var logStarting = false
    @ObservedObject var sensorLogger = WatchSensorManager()
    
    
    
    let recordingName = "o.m4a"
    
    
    
    var body: some View {
        VStack {
            Button(action: {
                
                
//                let dirPath = reecord().getDirectory()
//                let pathArray = [dirPath, recordingName]
//                guard let filePath = URL(string: pathArray.joined(separator: "/")) else { return }
//
//                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                                AVSampleRateKey:48000,
//                                AVNumberOfChannelsKey:1,
//                                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

                reecord().recordTapped()
                self.logStarting.toggle()
                
                if self.logStarting {
                    // 計測スタート
                    var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                    
                    print("sampling frequency = \(samplingFrequency) on watch")
                    
                    // なぜかサンプリング周波数が0のときは100にしておく
                    if samplingFrequency == 0 {
                        samplingFrequency = 100
                    }
                    
                    
                    
                    self.sensorLogger.startUpdate(Double(samplingFrequency))
                    
                }
                else {
                    self.sensorLogger.stopUpdate()
//                    audioRecorder.stop()
//                    audioRecorder.stop()

                    
                }
            }) {
                if self.logStarting {
                    Image(systemName: "pause.circle")
                }
                else {
                    Image(systemName: "play.circle")
                }
            }
            
            VStack {
                VStack {
                Text("Accelerometer").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.accX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accY))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.accZ))
                }.padding(.horizontal)
                }
                
                VStack {
                Text("Gyroscope").font(.headline)
                HStack {
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                    Spacer()
                    Text(String(format: "%.2f", self.sensorLogger.gyrX))
                }.padding(.horizontal)
                }

            }
        }
        
    }
}


public class reecord: NSObject, AVAudioRecorderDelegate
{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    func startRecording() {
        
        
        
        let recordingName = "o.m4a"
        
        let dirPath = reecord().getDirectory()
        let pathArray = [dirPath, recordingName]
        guard let filePath = URL(string: pathArray.joined(separator: "/")) else { return }
        
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                      AVSampleRateKey:48000,
                AVNumberOfChannelsKey:1,
             AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        
        
        print(filePath)
        
        do {
            
            let audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("\n \n recording did start \n \n")
            
        } catch {
            finishRecording(success: false)
            print("\n \n recording error \n \n")
        }
    }
    
    func finishRecording(success: Bool) {
        print("\n \n recording finishing \n \n")
        audioRecorder.stop()
        audioRecorder = nil
    

    }
    
    
    @objc func recordTapped() {
        print("\n \n record button tapped\n \n")
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("\n \n recording did finish \n \n ")
            finishRecording(success: false)

        }
    }
    
    func getDirectory()-> String {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return dirPath
        

    
    }}

//
//class RecInterface: WKInterfaceController {
//
//    let saveURl = FileManager.default.getDocumentsDirectory().appendingPathComponent("recording.wav")
//    var audioPlayer: AVAudioPlayer?
//
//
//    func recordBtn() {
//        presentAudioRecorderController(withOutputURL: saveURl, preset: .highQualityAudio){
//            (sucess, error) in
//            if sucess {
//                print("The recording is saved sucessfully")
//            }else{
//                print(error?.localizedDescription ?? "Unknown Error")
//            }
//        }
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

