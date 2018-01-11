//
//  BluetoothServices.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 23/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import Foundation

public struct KeyringBluetoothService {
    var serviceUuid: String
    var characteristicUuid: String
    var write: Bool
}

public struct KeyringService {
    var batteryService: KeyringBluetoothService
    var buttonService: KeyringBluetoothService
    var alarmService: KeyringBluetoothService
}

let AllKeyringServices: [KeyringService] = [
    KeyringService(batteryService: KeyringBluetoothService(serviceUuid: "180F", characteristicUuid: "2A19", write: false),
                   buttonService: KeyringBluetoothService(serviceUuid: "FFE0", characteristicUuid: "FFE1", write: false),
                   alarmService: KeyringBluetoothService(serviceUuid: "1802", characteristicUuid: "2A06", write: true))
]
