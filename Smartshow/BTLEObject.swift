//
//  BTLEObject.swift
//  BTLE-Demo
//

import Foundation
import CoreBluetooth

class BTLEObject: NSObject, ObservableObject {
    @Published var state: State = State() {
        didSet {
            //print(!updatePending && !skipNextWrite && state != oldValue)
            if self.state.isSetting {
                if !updatePending && !skipNextWrite && state != oldValue,
                    let settingsCharacteristic = settingsCharacteristic {
                    updatePending = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        var stringToWrite = self.state.settingString
                        print(stringToWrite)
                        if let data = stringToWrite.data(using: .utf8) {
                            // Do something with the data
                            //print(data)
                            self.devicePeripheral?.writeValue(data, for: settingsCharacteristic, type: .withResponse)
                        } else {
                            // Encoding failed
                            print("Unable to convert string to data using UTF-8 encoding.")
                        }
                        self.state.isSetting = false
                        self.updatePending = false
                    }
                }
                skipNextWrite = false
            }
            if self.state.isState {
                if !updatePending && !skipNextWrite && state != oldValue,
                    let stateCharacteristic = stateCharacteristic {
                    updatePending = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        var stringToWrite = self.state.stateString
                        print(stringToWrite)
                        if let data = stringToWrite.data(using: .utf8) {
                            // Do something with the data
                            //print(data)
                            self.devicePeripheral?.writeValue(data, for: stateCharacteristic, type: .withResponse)
                        } else {
                            // Encoding failed
                            print("Unable to convert string to data using UTF-8 encoding.")
                        }
                        self.state.isState = false
                        self.updatePending = false
                    }
                }
                skipNextWrite = false
            }
            if self.state.isCredential {
                if !updatePending && !skipNextWrite && state != oldValue,
                    let credentialsCharacteristic = credentialsCharacteristic {
                    updatePending = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        var stringToWrite = self.state.credentialString
                        print(stringToWrite)
                        if let data = stringToWrite.data(using: .utf8) {
                            // Do something with the data
                            //print(data)
                            self.devicePeripheral?.writeValue(data, for: credentialsCharacteristic, type: .withResponse)
                        } else {
                            // Encoding failed
                            print("Unable to convert string to data using UTF-8 encoding.")
                        }
                        self.state.isCredential = false
                        self.updatePending = false
                    }
                }
                skipNextWrite = false
            }
        }
    }
    
//    if self.state.isState {
//        var stringToWrite = self.state.stateString
//        print(stringToWrite)
//        if let data = stringToWrite.data(using: .utf8) {
//            // Do something with the data
//            //print(data)
//            self.devicePeripheral?.writeValue(data, for: stateCharacteristic!, type: .withResponse)
//        } else {
//            // Encoding failed
//            print("Unable to convert string to data using UTF-8 encoding.")
//        }
//        self.state.isSetting = false
//    }

    private var bluetoothManager: CBCentralManager!
    private var devicePeripheral: CBPeripheral?
    
    private var numberCharacteristic: CBCharacteristic?
    private var credentialsCharacteristic: CBCharacteristic?
    private var settingsCharacteristic: CBCharacteristic?
    private var stateCharacteristic: CBCharacteristic?
    
    private var updatePending: Bool = false
    private var skipNextWrite: Bool = false

    override init() {
        super.init()
        bluetoothManager = CBCentralManager(delegate: self,
                                            queue: nil)
    }
}

extension BTLEObject: CBCentralManagerDelegate {
    private static let DEVICE_NAME = "LAMPI b827ebf3462d"
    static let SERVICE_UUID = "0005A7D3-D8A4-4FEA-8174-1736E808C066"
    static let SETTINGS_UUID = CBUUID(string: "0001A7D3-D8A4-4FEA-8174-1736E808C066")
    static let STATE_UUID = CBUUID(string: "0004A7D3-D8A4-4FEA-8174-1736E808C066")
    static let CREDENTIALS_UUID = CBUUID(string: "0003A7D3-D8A4-4FEA-8174-1736E808C066")
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let services = [CBUUID(string:BTLEObject.SERVICE_UUID)]
            bluetoothManager.scanForPeripherals(withServices: services)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if peripheral.name == BTLEObject.DEVICE_NAME {
            print("Found \(BTLEObject.DEVICE_NAME)")

            devicePeripheral = peripheral

            bluetoothManager.stopScan()
            bluetoothManager.connect(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        state.isConnected = true

        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string:BTLEObject.SERVICE_UUID)])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral)")
        state.isConnected = false
    }
}

extension BTLEObject: CBPeripheralDelegate {
    static let SOME_NUMBER_UUID = "0004A7D3-D8A4-4FEA-8174-1736E808C066"

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print("Discovered device service")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            switch characteristic.uuid {

            case BTLEObject.CREDENTIALS_UUID:
                self.credentialsCharacteristic = characteristic
                devicePeripheral?.readValue(for: characteristic)
                devicePeripheral?.setNotifyValue(true, for: characteristic)

            case BTLEObject.SETTINGS_UUID:
                self.settingsCharacteristic = characteristic
                devicePeripheral?.readValue(for: characteristic)
                devicePeripheral?.setNotifyValue(true, for: characteristic)

            case BTLEObject.STATE_UUID:
                self.stateCharacteristic = characteristic
                devicePeripheral?.readValue(for: characteristic)
                devicePeripheral?.setNotifyValue(true, for: characteristic)

            default:
                continue
            }
        }
    }

//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("Value updated for characteristic with UUID: \(characteristic.uuid)")
//        if characteristic == numberCharacteristic,
//           let numberData = numberCharacteristic?.value {
//
//            let newNumber = Double(numberData[0]) / 255.0
//
//            skipNextWrite = true
//            state.number = newNumber
//        }
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Value updated for characteristic with UUID: \(characteristic.uuid)")
        var characteristicASCIIValue = NSString()
        
        guard characteristic == characteristic,
              
                let characteristicValue = characteristic.value,
              let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }
        
        characteristicASCIIValue = ASCIIstring
        
        print("Value Recieved: \((characteristicASCIIValue as String))")
    }
}



extension BTLEObject {
    struct State: Equatable {
        var settingString: String = ""
        var stateString: String = ""
        var credentialString: String = ""
        var isSetting: Bool = false
        var isState: Bool = false
        var isCredential: Bool = false
        var numberTest: Double = 0.0
        var number: Double = 0.0
        var isConnected: Bool = false
    }
}












































////
////  BTLE.swift
////  SmartShow
////
////  Created by Andre Yost on 5/3/23.
////
//
//import Foundation
//import CoreBluetooth
//
//class BTLEObject: NSObject, ObservableObject {
//    @Published var state: State = State() {
//        didSet {
////            if state != oldValue {
////                let stateCharacteristic = stateCharacteristic {
////                    var stateToWrite = "state: stop"
////                    let encodedStateString = stateToWrite.data(using: .utf8)
////                    let dataToWrite = Data(bytes: &encodedStateString, count: stateCharacteristic, type: .withResponse)
////                    print("UPDATED VALUE OVER BTLE")
////                }
////
////            }
//            //print(state != oldValue)
//            //if state != oldValue {
//            updateDevice()
//            //}
//        }
//    }
//
//    private func setupPeripheral() {
//        if let lampiPeripheral = lampiPeripheral  {
//            lampiPeripheral.delegate = self
//        }
//    }
//
//    private var bluetoothManager: CBCentralManager!
//    private var devicePeripheral: CBPeripheral?
//
//    var lampiPeripheral: CBPeripheral? {
//        didSet {
//            setupPeripheral()
//        }
//    }
//
//    private var numberCharacteristic: CBCharacteristic?
//    private var credentialsCharacteristic: CBCharacteristic?
//    private var settingsCharacteristic: CBCharacteristic?
//    private var stateCharacteristic: CBCharacteristic?
//
//    private var updatePending: Bool = false
//    private var skipNextWrite: Bool = false
//
//    override init() {
//        super.init()
//        bluetoothManager = CBCentralManager(delegate: self,
//                                            queue: nil)
//    }
//}
//
//extension BTLEObject: CBCentralManagerDelegate {
//    //#warning("Update DEVICE_NAME")
//    private static let DEVICE_NAME = "LAMPI b827ebf3462d"
//    private static let OUR_SERVICE_UUID = "0001A7D3-D8A4-4FEA-8174-1736E808C066"
//
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOn {
//            let services = [CBUUID(string:BTLEObject.OUR_SERVICE_UUID)]
//            bluetoothManager.scanForPeripherals(withServices: services)
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager,
//                        didDiscover peripheral: CBPeripheral,
//                        advertisementData: [String : Any],
//                        rssi RSSI: NSNumber) {
//        if peripheral.name == BTLEObject.DEVICE_NAME {
//            print("Found \(BTLEObject.DEVICE_NAME)")
//
//            devicePeripheral = peripheral
//
//            bluetoothManager.stopScan()
//            bluetoothManager.connect(peripheral)
//        }
//    }
//
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("Connected to peripheral: \(peripheral)")
//        state.isConnected = true
//
//        peripheral.delegate = self
//        peripheral.discoverServices([CBUUID(string:BTLEObject.OUR_SERVICE_UUID)])
//    }
//
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("Disconnected from peripheral: \(peripheral)")
//        state.isConnected = false
//    }
//}
//
//extension BTLEObject {
//    static let SERVICE_UUID = "7a4b0001-999f-4717-b63a-066e06971f59"
//    static let SETTINGS_UUID = CBUUID(string: "0001A7D3-D8A4-4FEA-8174-1736E808C066")
//    static let STATE_UUID = CBUUID(string: "0004A7D3-D8A4-4FEA-8174-1736E808C066")
//    static let CREDENTIALS_UUID = CBUUID(string: "0003A7D3-D8A4-4FEA-8174-1736E808C066")
//    //static let TEST_UUID = CBUUID(string: "0003A7D3-D8A4-4FEA-8174-1736E808C066")
//
//    private var shouldSkipUpdateDevice: Bool {
//        return skipNextWrite || updatePending
//    }
//
//    private func updateDevice(force: Bool = false) {
//        print("updateDevice boolean: \(state.isConnected)")
////        print(state.isConnected)
////        print(force)
////        print(!shouldSkipUpdateDevice)
//        if state.isConnected { //&& (force || shouldSkipUpdateDevice)
//            updatePending = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//                self?.writeState()
//                self?.writeSettings()
//                self?.writeCredential()
//
//                self?.updatePending = false
//            }
//        }
//        skipNextWrite = false
//    }
//
//    func writeOutgoingValue(data: String){
//
//        print("writeOUtgoingValue func called")
//
//        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
//
//        //if let lampiPeripheral = lampiPeripheral {
//            print("writeOUtgoingValue func called test 1")
//
//        if let stateCharacteristic = stateCharacteristic {
//            print("writeOUtgoingValue func called test 2")
//
//            lampiPeripheral?.writeValue(valueString!, for: stateCharacteristic, type: CBCharacteristicWriteType.withResponse)
//        }
//        //}
//    }
//
//    func writeState() {
//        if let stateCharacteristic = stateCharacteristic {
//            let stateString = "{state: " + state.playStop + "}"
//            print("stateString: \(stateString)")
//            guard var encodedStateString = stateString.data(using: .utf8) else {
//                print("Error encoding state string")
//                return
//            }
//            let data = Data(bytes: &encodedStateString, count: 1)
//            print("Data: \(data)")
//            lampiPeripheral?.writeValue(data, for: stateCharacteristic, type: .withResponse)
//
//
//
//
////            let stateString = "{state: \(MyVariables.playStopBool)}"
////            print("stateString: \(stateString)")
////            let encodedStateString = stateString.data(using: .utf8)
////            let data = Data(bytes: encodedStateString, count: 1)
////            print("Data: \(data)")
////            lampiPeripheral?.writeValue(data, for: stateCharacteristic, type: .withResponse)
//        }
//    }
//
//    func writeCredential() {
//        if let credentialsCharacteristic = credentialsCharacteristic {
//            let credString = "{token: " + MyVariables.accessToken + ", refresh_token: " + MyVariables.refreshToken + ", client_id: " + MyVariables.clientID + ", client_secret: " + MyVariables.clientSecret + "}"
//            let data = Data(bytes: credString, count: 4)
//            lampiPeripheral?.writeValue(data, for: credentialsCharacteristic, type: .withResponse)
//        }
//    }
//
//    func writeSettings() {
//        if let settingsCharacteristic = settingsCharacteristic {
//            let settingString = "{album: " + MyVariables.albumSelected + ", album_id: " + MyVariables.albumID + ", speed: " + MyVariables.speedSelected + ", animation: " + MyVariables.animationSelected + "}"
//            let data = Data(bytes: settingString, count: 4)
//            lampiPeripheral?.writeValue(data, for: settingsCharacteristic, type: .withResponse)
//        }
//    }
//
//}
//
//extension BTLEObject: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//
//        for service in services {
//            print("Found \(service)")
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        guard let characteristics = service.characteristics else { return }
//
//        for characteristic in characteristics {
//            switch characteristic.uuid {
//
//            case BTLEObject.CREDENTIALS_UUID:
//                self.credentialsCharacteristic = characteristic
//                peripheral.readValue(for: characteristic)
//                peripheral.setNotifyValue(true, for: characteristic)
//
//            case BTLEObject.SETTINGS_UUID:
//                self.settingsCharacteristic = characteristic
//                peripheral.readValue(for: characteristic)
//                peripheral.setNotifyValue(true, for: characteristic)
//
//            case BTLEObject.STATE_UUID:
//                self.stateCharacteristic = characteristic
//                peripheral.readValue(for: characteristic)
//                peripheral.setNotifyValue(true, for: characteristic)
//
//            default:
//                continue
//
//            }
//        }
//
//        // not connected until all characteristics are discovered
//        if self.credentialsCharacteristic != nil && self.settingsCharacteristic != nil && self.stateCharacteristic != nil {
//            skipNextWrite = true
//            state.isConnected = true
//            print("ALL CHARACTERISTICS DISCOVERED")
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("Value updated for characteristic with UUID: \(characteristic.uuid)")
//        skipNextWrite = true
//
//        guard let updatedValue = characteristic.value,
//              !updatedValue.isEmpty else { return }
//
//        switch characteristic.uuid {
//        case BTLEObject.STATE_UUID:
//            state.playStop = parseState(for: String(data: updatedValue, encoding: .utf8)!)
//
//        default:
//            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
//        }
//    }
//}
//
//extension BTLEObject {
//    struct State: Equatable {
//        var number: Double = 0.0
//        var start: Bool = false
//        var isConnected: Bool = false
//        var playStop: String = ""
//    }
//}
//
//private func parseCredentials(for value: [String]) -> (accToken: String, refrToken: String, clientID: String, clientSecret: String) {
//    return (accToken: value[0],
//            refrToken: value[1],
//            clientID: value[2],
//            clientSecret: value[3])
//}
//
//private func parseState(for value: String) -> String {
//    return value
//}
//
//
////            if characteristic.uuid == CBUUID(string: BTLEObject.SERVICE_UUID) {
////                print("Found characteristic with UUID: \(BTLEObject.SERVICE_UUID)")
////
////                numberCharacteristic = characteristic
////                devicePeripheral?.readValue(for: characteristic)
////                devicePeripheral?.setNotifyValue(true, for: characteristic)
////            }
//
////        if characteristic == numberCharacteristic,
////           let numberData = numberCharacteristic?.value {
////
////            //let newNumber = Double(numberData[0]) / 255.0
////
////            skipNextWrite = true
////            //state.number = newNumber
////        }




//                    var intToWrite = UInt8(self.state.number * 255.0)
//                    print(intToWrite)
//                    let dataToWrite = Data(bytes: &intToWrite, count: 1)
//                    print(dataToWrite)
//                    self.devicePeripheral?.writeValue(dataToWrite, for: numberCharacteristic, type: .withResponse)
                    
//                    var intToWrite2 = UInt8(self.state.numberTest * 255.0)
//                    print(intToWrite2)
//                    let dataToWrite2 = Data(bytes: &intToWrite2, count: 1)
//                    print(dataToWrite2)
//                    self.devicePeripheral?.writeValue(dataToWrite2, for: numberCharacteristic, type: .withResponse)



//        for characteristic in characteristics {
//            if characteristic.uuid == BTLEObject.STATE_UUID {
//                print("Found characteristic with UUID: \(BTLEObject.STATE_UUID)")
//
//                settingsCharacteristic = characteristic
//                devicePeripheral?.readValue(for: characteristic)
//                devicePeripheral?.setNotifyValue(true, for: characteristic)
//            }
//        }



//                    var charToWrite =
//                    print(charToWrite)
//                    let dataToWrite = Data(bytes: &charToWrite, count: self.state.bigString.count)
//                    print(dataToWrite)
//                    self.devicePeripheral?.writeValue(dataToWrite, for: settingsCharacteristic, type: .withResponse)

//                    var charToWrite = self.state.bigString
//                    print(charToWrite)
//                    let dataToWrite = Data(bytes: &charToWrite, count: self.state.bigString.count)
//                    print(dataToWrite)
//                    self.devicePeripheral?.writeValue(dataToWrite, for: settingsCharacteristic, type: .withResponse)

//                    var stateString = "{state: " + self.state.numberT + "}"
//                    print("stateString: \(stateString)")
//                    guard var encodedStateString = stateString.data(using: .utf8) else {
//                        print("Error encoding state string")
//                        return
//                    }
//                    let data = Data(bytes: &encodedStateString, count: 1)
//                    print("Data: \(data)")
//                    self.devicePeripheral?.writeValue(data, for: numberCharacteristic, type: .withResponse)
