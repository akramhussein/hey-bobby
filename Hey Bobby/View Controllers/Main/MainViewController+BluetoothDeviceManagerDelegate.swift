//
//  MainViewController+BluetoothDeviceManagerDelegate.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 22/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import Foundation
import CoreBluetooth
import DefaultsKit
import MBProgressHUD
import UIKit

extension MainViewController: BluetoothDeviceManagerDelegate {
    
    func peripheralCharacteristicValueUpdated(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data) {
        let val = value.to(type: Int.self)
        if val == 1 {
            let enabled = Defaults.shared.get(for: Keys.KeyringButton) ?? false
            if enabled {
                print("Bluetooth Clicker pressed")
                self.peripheral = peripheral
                self.clicks += 1
                self.bluetoothClickerTimer.invalidate()
                self.bluetoothClickerTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                                  target: self,
                                                                  selector: #selector(MainViewController.bluetoothClickerTimerElapsed(_:)),
                                                                  userInfo: nil,
                                                                  repeats: false)
            }
        }
    }
    
    func bluetoothManagerChangedReadyState(bluetoothManager: BluetoothDeviceManager, ready: Bool) {
        if ready { self.startOrStopKeyringButtonScanning() }
    }
    
    func bluetoothManagerFinishedScanning(bluetoothManager: BluetoothDeviceManager) {}
    
    func peripheralConnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral) {
        let state = UIApplication.shared.applicationState
        if case .active = state {
            guard let view = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
            let hud = MBProgressHUD.createCompletionHUD(view: view, message: "KeyringButton.Connected".localized)
            hud.hide(animated: true, afterDelay: 5.0)
        } else {
            self.createLocalNotification(connected: true)
        }
        
    }
    
    func peripheralDisconnected(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral) {
        let state = UIApplication.shared.applicationState
        if case .active = state {
            guard let view = UIApplication.shared.keyWindow?.rootViewController?.view else { return }
            let hud = MBProgressHUD.createFailedHUD(view: view, message: "KeyringButton.Disconnected".localized)
            hud.hide(animated: true, afterDelay: 5.0)
        } else {
            self.createLocalNotification(connected: false)
        }
    }
    
    func peripheralCharacteristicFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func peripheralFound(bluetoothManager: BluetoothDeviceManager, peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        self.bluetoothManager.connectToPeripherals(peripherals: [peripheral])
    }
}

