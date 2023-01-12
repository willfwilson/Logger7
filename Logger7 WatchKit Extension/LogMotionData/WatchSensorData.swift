//
//  WatchSensorData.swift
//  LoggerWatchPods WatchKit Extension
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation

//
//
//
import WatchConnectivity
//
//
//



//
//
//
//var saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//
//

// 文字列を長さで分割するextension
extension String {
    func components(withLength length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
    }
}

struct SensorData {
    var accelerometerData: String
    var gyroscopeData: String
    
    // 1秒毎にiPhoneに送信するデータ
    private var accelerometerDataSec: String
    private var gyroscopeDataSec: String
    
    
    // iPhone側にデータを送信するため
    var connector = PhoneConnector()
    
    init() {
        self.accelerometerData = ""
        self.gyroscopeData = ""
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    mutating func accAppend(time: String, x: Double, y: Double, z: Double, sensorType: SensorType) {
        var line = time + ","
        line.append(String(x) + ",")
        line.append(String(y) + ",")
        line.append(String(z) + "\n")
        
        switch sensorType {
        case .watchAccelerometer:
            self.accelerometerData.append(line)
            self.accelerometerDataSec.append(line)
        case .watchGyroscope:
            self.gyroscopeData.append(line)
            self.gyroscopeDataSec.append(line)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    mutating func gyrAppend(time: String, x: Double, y: Double, z: Double, qx: Double, qy: Double, qz: Double, qw: Double,roll: Double,pitch: Double,yaw: Double, sensorType: SensorType) {
        var line = time + ","
        line.append(String(x) + ",")
        line.append(String(y) + ",")
        line.append(String(z) + ",")
        line.append(String(qx) + ",")
        line.append(String(qy) + ",")
        line.append(String(qz) + ",")
        line.append(String(qw) + ",")
        line.append(String(roll) + ",")
        line.append(String(pitch) + ",")
        line.append(String(yaw) + "\n")
        
        switch sensorType {
        case .watchAccelerometer:
            self.accelerometerData.append(line)
            self.accelerometerDataSec.append(line)
        case .watchGyroscope:
            self.gyroscopeData.append(line)
            self.gyroscopeDataSec.append(line)
        default:
            print("No data of \(sensorType) is available.")
        }
    }
    
    mutating func reset() {
        self.accelerometerData = ""
        self.gyroscopeData = ""
        
        self.accelerometerDataSec = ""
        self.gyroscopeDataSec = ""
    }
    
    
    
    
    //
    //
    //
    //
    //
//    func sendAudio() {
//        let AudioData = NSData(contentsOf: saveURL!)
//        sendAudioFile(file: AudioData!) // Quicker.
//    }
//
//    func sendAudioFile(file: NSData) {
//        WCSession.default.sendMessageData(file as Data, replyHandler: { (AudioData) -> Void in
//            // handle the response from the device
//        }) { (error) -> Void in
//            print("here")
//            print("error: \(error.localizedDescription)")
//        }
//    }
    //
    //
    //
    //
    //
    
    
    
    
    // iPhone側にcsv形式のStringを送信する
    mutating func sendAccelerometerData() {
        //        print("Size: \(self.accelerometerDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "ACC_DATA", value: self.accelerometerDataSec) {
            self.accelerometerDataSec = ""
        }
    }
    
    mutating func sendGyroscopeData() {
        //        print("Size: \(self.gyroscopeDataSec.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        if self.connector.send(key: "GYR_DATA", value: self.gyroscopeDataSec) {
            self.gyroscopeDataSec = ""
        }
    }
    
    mutating func sendDataAfterStop(splitSize: Int) {
        
        
//
//
        DispatchQueue.main.async{
            
            var test = true
            print(WCSession.default.activationState)
            while test == true
            {
                if WCSession.default.isReachable && test == true
                {
                    
                    print(WCSession.default.transferFile(saveURL!,metadata: nil) as Any)
                    test = false
                }
            }
//            test = true
//            print(WCSession.default.activationState)
//            while test == true
//            {
//                if WCSession.default.isReachable && test == true
//                {
//
//                    print(WCSession.default.transferFile(straddress!,metadata: nil) as Any)
//                    test = false
//                }
//            }
//
//            test = true
//
//
        print(WCSession.default.outstandingFileTransfers)

        print(WCSession.default.hasContentPending)


        print("waiting...")
        while WCSession.default.outstandingFileTransfers != []
        {
            
//            print("waiting here")
        }
        print(WCSession.default.outstandingFileTransfers)
        }
//
        print("All Size: \(self.accelerometerData.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        let accComponents = self.accelerometerData.components(withLength: splitSize * 1024)
        print(accComponents.count)
        accComponents.forEach { (component) in
            print("Size: \(component.lengthOfBytes(using: String.Encoding.utf8)) byte")
            if self.connector.send(key: "ACC_ALL", value: component) {
                print("Success")
            }
        }
        
        print("All Size: \(self.gyroscopeData.lengthOfBytes(using: String.Encoding.utf8)) byte")
        
        let gyrComponents = self.gyroscopeData.components(withLength: splitSize * 1024)
        print(gyrComponents.count)
        gyrComponents.forEach { (component) in
            print("Size: \(component.lengthOfBytes(using: String.Encoding.utf8)) byte")
            if self.connector.send(key: "GYR_ALL", value: component) {
                print("Success")
            }
        }
        
        
        print("All data sent")
        
        
    }
}
