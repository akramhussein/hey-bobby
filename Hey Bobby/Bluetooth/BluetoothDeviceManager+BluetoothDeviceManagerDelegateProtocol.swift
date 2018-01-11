//
//  BluetoothDeviceManager+BluetoothDeviceManagerDelegateProtocol.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 23/08/2017.
//  Copyright © 2017 TFH. All rights reserved.
//

import CoreBluetooth

public protocol BluetoothDeviceManagerDelegate: class {
	func bluetoothManagerChangedReadyState(bluetoothManager: BluetoothDeviceManager, ready: Bool)
    
    func peripheralFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [String: Any], RSSI: NSNumber)

    func bluetoothManagerFinishedScanning(bluetoothManager: BluetoothDeviceManager)

    func peripheralConnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)

    func peripheralDisconnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral)

    func peripheralCharacteristicFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, characteristic: CBCharacteristic)
    
    func peripheralCharacteristicValueUpdated(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data)

}
