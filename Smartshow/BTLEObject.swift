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
