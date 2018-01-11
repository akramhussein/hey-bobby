//
//  BluetoothDeviceManager+CBPeripheralDelegate.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 15/06/2015.
//  Copyright © 2017 TFH. All rights reserved.
//

import CoreBluetooth

extension BluetoothDeviceManager: CBPeripheralDelegate {

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("BLUETOOTH: discovering services \(String(describing: error?.localizedDescription)) for: \(String(describing: peripheral.name))")
            return
        }

        print("BLUETOOTH: didDiscoverServices for \(String(describing: peripheral.name))")

        if let services = peripheral.services {
            for service in services {
                if let _ = service.characteristics {
                    // Already discovered characteristic before, DO NOT do it again
                    print("BLUETOOTH: Characteristics already discovered for \(String(describing: peripheral.name))")
                    self.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil)
                } else {
                    print("BLUETOOTH: Discovering characteristics for \(String(describing: peripheral.name)) - \(service)")
                    // Need to discover characteristics
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("BLUETOOTH: discovering characteristics \(String(describing: error?.localizedDescription)) for: \(String(describing: peripheral.name))")
            return
        }

        print("BLUETOOTH: didDiscoverCharacteristicsForService for \(String(describing: peripheral.name)) - \(service)")
        for characteristic in service.characteristics! {
            // Cache relevant CBCharacteristics against their CBPeripherals for later use
            self.characteristics[peripheral, default: [CBCharacteristic]()].append(characteristic)
            
            // Notify delegate of update
            self.delegate?.peripheralCharacteristicFound(bluetoothManager: self, peripheral: peripheral, characteristic: characteristic)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("BLUETOOTH: updating value for characteristic \(String(describing: error?.localizedDescription)) for: \(String(describing: peripheral.name))")
            return
        }
        guard let value = characteristic.value else { return }
        self.delegate?.peripheralCharacteristicValueUpdated(bluetoothManager: self, peripheral: peripheral, characteristic: characteristic, value: value)
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("BLUETOOTH: writing value to characteristic \(String(describing: error?.localizedDescription)) for: \(String(describing: peripheral.name))")
            return
        }
        print("BLUETOOTH: Wrote value to characteristic: \(characteristic) for: \(String(describing: peripheral.name))")
    }
}
