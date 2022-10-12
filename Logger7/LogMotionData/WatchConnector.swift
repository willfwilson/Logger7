//
//  WatchConnector.swift
//  LoggerWatchPods
//
//  Created by Satoshi on 2020/10/30.
//

import Foundation
import UIKit
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    var lastRecievedFile:URL?
    var sensorDataManager = SensorDataManager.shared
    
    // Sensor values from Apple Watch
    @Published var accX = 0.0
    @Published var accY = 0.0
    @Published var accZ = 0.0
    @Published var gyrX = 0.0
    @Published var gyrY = 0.0
    @Published var gyrZ = 0.0
    
    @Published var isReceivedAccData = false
    @Published var isReceivedGyrData = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            print(WCSession.default.activate())
            print("wcsession activated on phone")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state = \(activationState.rawValue)")
    }
    
    ///////////////
    ///
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
    print("didFinish fileTransfer")
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
   
        
        
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let tempDocsDir = dirPaths[0] as String
            let docsDir = tempDocsDir.appending("/")
            let filemgr = FileManager.default
        DispatchQueue.main.sync{
            do {
                
                
                
                let fileName = (file.fileURL.path).components(separatedBy: "/")[(((file.fileURL.path).components(separatedBy: "/")).count)-1]
                
                let fileAttributes1 = try? FileManager.default.attributesOfItem(atPath: file.fileURL.path)
                let bytes1 = fileAttributes1![.size] as? Int64
                let bcf1 = ByteCountFormatter()
                bcf1.allowedUnits = [.useKB]
                bcf1.countStyle = .file
                let string1 = bcf1.string(fromByteCount: bytes1!)
                print("\n \n recieved file mbs:")
                print(string1)
                
                try filemgr.copyItem(atPath: file.fileURL.path, toPath: docsDir + fileName)
                
                
                
            } catch let error as NSError {
                print("Error moving file: \(error.description)")
                
            }
            
            let fileAttributes2 = try? FileManager.default.attributesOfItem(atPath: docsDir + (file.fileURL.path).components(separatedBy: "/")[(((file.fileURL.path).components(separatedBy: "/")).count)-1])
            let bytes2 = fileAttributes2![.size] as? Int64
            let bcf2 = ByteCountFormatter()
            bcf2.allowedUnits = [.useKB]
            bcf2.countStyle = .file
            let string2 = bcf2.string(fromByteCount: bytes2!)
            print("\n \n copied file mbs:")
            print(string2)
            
            
            
            
            
            
            print("didReceive",file)
        }
    }
    ///////////////
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {

        DispatchQueue.main.async {
            // iPhone appで表示する用
            if let accData = message["ACC_DATA"] as? String {

                if accData.count != 0 {
                    // iPhone上で表示する
                    let accDataDouble = self.stringToDouble(data: accData)
                    self.accX = accDataDouble[0]
                    self.accY = accDataDouble[1]
                    self.accZ = accDataDouble[2]
                }
            }
            
            if let gyrData = message["GYR_DATA"] as? String {
                
                if gyrData.count != 0 {
                    let gyrDataDouble = self.stringToDouble(data: gyrData)
                    self.gyrX = gyrDataDouble[0]
                    self.gyrY = gyrDataDouble[1]
                    self.gyrZ = gyrDataDouble[2]
                }
            }
            
            // データ保存用
            if let accAllData = message["ACC_ALL"] as? String {
                self.sensorDataManager.append(line: accAllData, sensorType: .watchAccelerometer)
                self.isReceivedAccData = true
                print("Received")
            }
            
            if let gyrAllData = message["GYR_ALL"] as? String {
                self.sensorDataManager.append(line: gyrAllData, sensorType: .watchGyroscope)
                self.isReceivedGyrData = true
                print("Received")
            }
        }
    }
    
    // Apple Watchから送られてくるStringをDoubleのxyzに分解する
    private func stringToDouble(data: String) -> [Double] {
        // 改行コードを置き換える
        let dataNoLF = data.replacingOccurrences(of: "\n", with: "")
        // カンマ区切り
        let array = dataNoLF.components(separatedBy: ",")
        
        // String to Double
        // Nil Coalescing Operator
        let x = Double(array[1]) ?? Double.nan
        let y = Double(array[2]) ?? Double.nan
        let z = Double(array[3]) ?? Double.nan
        
        let dataDouble = [x, y, z]
        
        return dataDouble
    }
}
