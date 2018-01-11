//
//  BluetoothDeviceManager.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 15/06/2015.
//  Copyright © 2017 TFH. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

open class BluetoothDeviceManager: NSObject {

    public static let shared = BluetoothDeviceManager()

    public var reconnectIfDisconnected = true

    public enum AccessoryConnectionState: String {
        case disconnected, connected, characteristicsUpdated
    }

    public static let DefaultScanTime = 30.0 // seconds

    internal var bluetoothOn = false
    internal var scanTimer = Timer()
    internal var centralManager: CBCentralManager!
    internal var peripherals = Set<CBPeripheral>()
    internal var characteristics = [CBPeripheral: [CBCharacteristic]]()

    // List of acceptable UUIDs for services & characteristics
    internal var availableServiceCBUUIDs: [CBUUID] = {
        BluetoothDeviceManager.availableServices.flatMap { CBUUID(string: $0.serviceUuid) }
    }()

    internal var availableWriteCharacteristicCBUUIDs: [CBUUID] = {
        BluetoothDeviceManager.availableWriteCharacteristics.flatMap { CBUUID(string: $0.characteristicUuid) }
    }()

    
    internal var availableReadCharacteristicCBUUIDs: [CBUUID] = {
        BluetoothDeviceManager.availableReadCharacteristics.flatMap { CBUUID(string: $0.characteristicUuid) }
    }()

    public static let availableServices: [KeyringBluetoothService] = {
        return AllKeyringServices.flatMap{ [$0.batteryService, $0.alarmService, $0.buttonService] }
    }()

    public static let availableWriteCharacteristics: [KeyringBluetoothService] = {
        BluetoothDeviceManager.availableServices.filter{ $0.write }
    }()

    public static let availableReadCharacteristics: [KeyringBluetoothService] = {
        BluetoothDeviceManager.availableServices.filter{ !$0.write }
    }()
    
    // Delegate
    public weak var delegate: BluetoothDeviceManagerDelegate?

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth Functions

    public func searchForDevices(time: Double = BluetoothDeviceManager.DefaultScanTime) {
        // Cancel any previous requests to stop this
        self.scanTimer.invalidate()

        // Scan for devices
        self.startSearchingForDevices()

        // Setup timer
//        self.scanTimer = Timer.scheduledTimer(timeInterval: time,
//                                              target: self,
//                                              selector: #selector(BluetoothDeviceManager.stopSearchingForDevices),
//                                              userInfo: nil,
//                                              repeats: false)
    }

    private func startSearchingForDevices() {
        print("BLUETOOTH: Start searching for devices")

        if self.centralManager.state == .poweredOn {
            if self.availableServiceCBUUIDs.count > 0 {
                self.centralManager.scanForPeripherals(withServices: self.availableServiceCBUUIDs, options: nil)
            } else {
                print("BLUETOOTH: No available service UUIDs to scan")
            }
        } else {
            // Perhaps throw error?
            print("BLUETOOTH: Bluetooth not powered on, unable to scan for peripherals")
        }
    }

    @objc public func stopSearchingForDevices() {
        print("BLUETOOTH: Stop searching for devices, found \(self.peripherals)")

        self.centralManager.stopScan()
        self.delegate?.bluetoothManagerFinishedScanning(bluetoothManager: self)
    }

    public func connectToPeripherals(peripherals: [CBPeripheral]) {
        for peripheral in peripherals {
            print("BLUETOOTH: Connecting to peripheral \(String(describing: peripheral.name)) - \(peripheral.identifier.uuidString)")
            self.centralManager.connect(peripheral, options: nil)
        }
    }

    public func disconnectFromPeripherals(peripherals: [CBPeripheral]) {
        for peripheral in peripherals {
            print("BLUETOOTH: Disconnecting from peripheral \(String(describing: peripheral.name)) - \(peripheral.identifier.uuidString)")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    private func compareCBUUID(uuid1: CBUUID, uuid2: CBUUID) -> Bool {
        return (uuid1.uuidString == uuid2.uuidString)
    }

    private func findServiceFromUUID(uuid: CBUUID, peripheral: CBPeripheral) -> CBService? {
        for service in peripheral.services! {
            return self.compareCBUUID(uuid1: service.uuid, uuid2: uuid) ? service : nil
        }
        return nil
    }

    private func findCharacteristicFromUUID(uuid: CBUUID, service: CBService) -> CBCharacteristic? {
        for characteristic in service.characteristics! {
            return self.compareCBUUID(uuid1: characteristic.uuid, uuid2: uuid) ? characteristic : nil
        }
        return nil
    }

    public func sendAlertAcknowledgement(peripheral: CBPeripheral) {
        // Fetch cached characteristic for peripheral
        guard let charsForPeripheral = self.characteristics[peripheral] else { return }
        let cachedChars = Set(charsForPeripheral.map{ $0.uuid.uuidString })
        let possibleChars = Set(AllKeyringServices.map{ $0.alarmService.characteristicUuid })
        let intersection = Array(cachedChars.intersection(possibleChars))
        let chars = charsForPeripheral.filter{ intersection.contains($0.uuid.uuidString) }
        for char in chars {
            let data = Data(bytes: [1], count: 1)
            print("BLUETOOTH: Sending Acknowledgement: char: \(char), Data: \(data.description) to name: \(String(describing: peripheral.name))")
            peripheral.writeValue(data, for: char, type: .withoutResponse)
        }
    }
}
