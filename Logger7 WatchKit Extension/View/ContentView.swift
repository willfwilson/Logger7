//
//  ContentView.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//
import SwiftUI //
import WatchKit
import AVFoundation

var audioRecorder : AVAudioRecorder!
var saveURL:URL?
var straddress:URL?
//let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
let settings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
              AVSampleRateKey:44100,
        AVNumberOfChannelsKey:1,
//     AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue]
        AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue]
let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]


struct ContentView: View {
    @State private var logStarting = false
    @ObservedObject var sensorLogger = WatchSensorManager()
    let recordingSession = AVAudioSession.sharedInstance()
    
//    static var timearray:[String] = []
    @State private var timearray:[String] = []
    
    
//    let recordingName = "o.m4a"
    
    
    
    var body: some View {
        VStack {
            
            Button(action: {
                
               
//                reecord().recordTapped()
                
                
                self.logStarting.toggle()
//                var timearray = ["AudioRec"]   // *****new
                
//                print(ContentView.timearray)
                if self.logStarting {

                    
                    
                    
                    var samplingFrequency = UserDefaults.standard.integer(forKey: "frequency_preference")
                    let audioFilename = documentPath.appendingPathComponent(("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH-mm-ss")).m4a").replacingOccurrences(of: " ", with: "_"))
//                    let audioFilename = documentPath.appendingPathComponent("\(getTimestamp()).m4a")
                    saveURL = audioFilename
                    print("sampling frequency = \(samplingFrequency) on watch")
                    print(audioFilename)

                    if samplingFrequency == 0 {
                        samplingFrequency = 500
                    }
                    
                    
                    let session = AVAudioSession.sharedInstance()
                    try! session.setCategory(AVAudioSession.Category.playAndRecord)
                    DispatchQueue.main.async {
                        var astart=getTimestamp()
                        if astart == ""
                        {
                            astart = "error"
                        }
                        
//                        do
////                        {
//                            astart = try getTimestamp()
//                        }
//                        catch
//                        {
//                            astart = "\(error)"
//                            print("Something went wrong: \(error)")
                        
                            
                        
                        timearray.append("AudioRec-Start_"+astart)
    //                    print(ContentView.timearray)
                    }
                    try! audioRecorder = AVAudioRecorder(url: audioFilename, settings: settings)
                    audioRecorder.delegate
                        audioRecorder.isMeteringEnabled = true
                        audioRecorder.prepareToRecord()
//                        timearray.append("AudioRec-Start_"+getTimestamp())
                        //timearray.append("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH-mm-ss"))") // *****new
                         // *****new
                        audioRecorder.record()



                    self.sensorLogger.startUpdate(Double(samplingFrequency))
//                    reecord().startRecording()

                }
                else {
//                    reecord().finishRecording(success:true)
                    self.sensorLogger.stopUpdate()
                    audioRecorder.stop()
                    //timearray.append("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH-mm-ss"))") // *****new
                    timearray.append("-End_"+getTimestamp()) // *****new
                  
//                    var newfilename = timearray.joined()+".m4a" // *****new
                    var newfilename = timearray.joined()+".wav" // *****new
                    
                    print(newfilename) // *****new
                    
                    let stringfile = (timearray.joined()+".txt")
                    straddress = documentPath.appendingPathComponent((timearray.joined()+".txt").replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-"))
                    do {try stringfile.write(to: documentPath.appendingPathComponent(timearray.joined()+".txt"), atomically: true, encoding: String.Encoding.utf8)}catch{}
                    
                 
                    timearray.removeAll()
                    let destinationPath = documentPath.appendingPathComponent(newfilename.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-"))
                    print(saveURL!)
                    print(destinationPath)// *****new
                    do{try FileManager.default.moveItem(at: saveURL!, to: destinationPath) }catch{print("Something went wrong: \(error)")}// *****new
                    saveURL = destinationPath// *****new
//


                    
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
                Text("Accelerometer").font(.headline).onAppear {
                    
                    

                    do {
                        
                        
//                        print(try reecord().recordingSession?.setCategory(.record, mode: .default) as Any)
//
//
//                        print(try reecord().recordingSession?.setActive(true) as Any)
//
//                        }
//                        catch let error{
//                            print((error.localizedDescription))
//
              
                        try reecord().recordingSession?.setCategory(.record, mode: .default)

//                        print("\n \n \n rec session category set\n \n \n")
                        try reecord().recordingSession?.setActive(true)
//
//                        print( AVAudioSession.RecordPermission(rawValue: <#UInt#>) )

//                        print("\n \n \n rec session set active\n \n \n")
//                        reecord().recordingSession?.requestRecordPermission() { allowed in
//
//                                if allowed {
//                                    print("\n \n \n rec session allowed\n \n \n")
//                                } else {
//                                    // failed to record!
//                                    print("\n \n \n rec session not allowed\n \n \n")
//                                }
//                            print("\n \n \n hmm\n \n \n")
//                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
//
//
                 
                
                    }
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
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true) }
        catch { }
        
    
        reecord().recordingSession?.requestRecordPermission() { allowed in
            
                if allowed {
                    print("\n \n \n rec session allowed\n \n \n")
                } else {
                    // failed to record!
                    print("\n \n \n rec session not allowed\n \n \n")
                }
            print("\n \n \n hmm\n \n \n")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let audioFilename = documentPath.appendingPathComponent("\(getTimestamp()).m4a")
        let audioFilename = documentPath.appendingPathComponent("\(getTimestamp()).wav")
        
//        let recordingName = "o.m4a"
        
//        let dirPath = reecord().getDirectory()
//        let pathArray = [dirPath, recordingName]
//        guard let filePath = URL(string: pathArray.joined(separator: "/")) else { return }
//
//        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        let settings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                        
                      AVSampleRateKey:44100,
                AVNumberOfChannelsKey:1,
             AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue]
        
        

        
        do {
            

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()

            print(audioRecorder.record())
            print("\n \n recording did start \n \n")
            
        } catch let error{
            finishRecording(success: false)
            print(error.localizedDescription)
        }
    }
    
    func finishRecording(success: Bool) {
        print("\n \n recording finishing \n \n")
        audioRecorder?.stop()
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


