//
//  BluetoothDeviceManager.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 15/06/2015.
//  Copyright © 2017 TFH. All rights reserved.
//

import CoreBluetooth

extension BluetoothDeviceManager: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("BLUETOOTH: CoreBluetooth BLE hardware is powered on and ready")
            self.bluetoothOn = true
        case .poweredOff:
            print("BLUETOOTH: CoreBluetooth BLE hardware is powered off")
            self.bluetoothOn = false
        case .resetting:
            print("BLUETOOTH: CoreBluetooth BLE hardware is resetting")
            self.bluetoothOn = false
        case .unauthorized:
            print("BLUETOOTH: CoreBluetooth BLE state is unauthorized")
            self.bluetoothOn = false
        case .unknown:
            print("BLUETOOTH: CoreBluetooth BLE state is unknown")
            self.bluetoothOn = false
        case .unsupported:
            print("BLUETOOTH: CoreBluetooth BLE hardware is unsupported on this platform")
            self.bluetoothOn = false
        }
     
        if self.bluetoothOn {
            self.delegate?.bluetoothManagerChangedReadyState(bluetoothManager: self, ready: true)
        } else {
            self.delegate?.bluetoothManagerChangedReadyState(bluetoothManager: self, ready: false)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self

        if let _ = peripheral.services {
            // Already discovered services, DO NOT re-discover. Just pass along the peripheral.
            print("BLUETOOTH: Services already discovered for \(String(describing: peripheral.name))")
            self.peripheral(peripheral, didDiscoverServices: nil)
        } else {
            // Should discover services
            print("BLUETOOTH: Discovering services for \(String(describing: peripheral.name))")
            peripheral.discoverServices(self.availableServiceCBUUIDs)
        }

        print("BLUETOOTH: Connected to peripheral: \(peripheral.identifier.uuidString), called: \(String(describing: peripheral.name))")
        self.delegate?.peripheralConnected(bluetoothManager: self, peripheral: peripheral)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BLUETOOTH: Lost connection to peripheral: \(peripheral.identifier.uuidString), called: \(String(describing: peripheral.name))")

        self.delegate?.peripheralDisconnected(bluetoothManager: self, peripheral: peripheral)

        if self.reconnectIfDisconnected {
            self.centralManager.connect(peripheral, options: nil)
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        print("BLUETOOTH: Found peripheral: \(peripheral.identifier.uuidString)")
        print("BLUETOOTH: Advertisement Data: \(advertisementData)")
        print("BLUETOOTH: Name: \(peripheral.name ?? "unknown")")

        self.peripherals.insert(peripheral)

        print("BLUETOOTH: Total scanned peripheral count: \(self.peripherals.count)")

        // Notify delegate of new peripheral found
        self.delegate?.peripheralFound(bluetoothManager: self, peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BLUETOOTH: Failed to connect to peripheral. Error: \(String(describing: error?.localizedDescription))")
    }

}
