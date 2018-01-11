//
//  MainViewController.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import UIKit
import MediaPlayer
import AudioToolbox
import CoreBluetooth
import MBProgressHUD
import Eureka
import DefaultsKit

final class MainViewController: FormViewController {

    // MARK: Properties

    var bluetoothManager = BluetoothDeviceManager.shared
    var peripheral: CBPeripheral?
    
    // MARK: View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .primaryColor
        self.title = "Main.Title".localized

        self.tableView.backgroundColor = .primaryColor
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none

        SwitchRow.defaultCellUpdate = { cell, _ in
            cell.backgroundColor = .primaryColor
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
            cell.switchControl.onTintColor = .alertLowColor
            cell.switchControl.backgroundColor = .alertHighColor
            cell.switchControl.layer.cornerRadius = 16
        }

        ButtonRow.defaultCellUpdate = { cell, _ in
            cell.backgroundColor = .primaryColor
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 19.0)
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.tintColor = .white
        }

        self.form
            +++ Section(header: "", footer: "Main.KeyringButtons.Footer".localized)

            <<< SwitchRow("keyring_buttons") { row in
                row.title = "Main.KeyringButtons.Title".localized
                row.value = Defaults.shared.get(for: Keys.KeyringButton) ?? false
                 row.cell.imageView?.image = UIImage(named: "KeyringButton")
            }.onChange { row in
                Defaults.shared.set(row.value!, for: Keys.KeyringButton)
                self.startOrStopKeyringButtonScanning()
            }

            <<< ButtonRow("keyring_buttons_setup") { row in
                row.title = "Main.Setup".localized
            }.onCellSelection { _, _ in
                self.navigationController?.pushViewController(KeyringButtonsSetupViewController(), animated: true)
            }
        
        // Register for Local Notifications
        UIApplication
            .shared
            .registerUserNotificationSettings(
                UIUserNotificationSettings(types: [.sound, .badge, .alert],
                                           categories: nil))
        
        self.bluetoothManager.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Helpers
    
    func startOrStopKeyringButtonScanning() {
        let enabled = Defaults.shared.get(for: Keys.KeyringButton) ?? false
        if enabled {
            // Ask user to turn on Bluetooth
            _ = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
            self.bluetoothManager.delegate = self
            self.bluetoothManager.searchForDevices()
        } else {
            self.bluetoothManager.delegate = nil
            self.bluetoothManager.stopSearchingForDevices()
        }
    }
    
    func vibrate() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }

    // MARK: Keyring Button

    var clicks = 0
    var bluetoothClickerTimer = Timer()

    @objc func bluetoothClickerTimerElapsed(_ sender: Any) {
        self.bluetoothClickerTimer.invalidate()

        let severity: Severity!
        switch self.clicks {
            case 1: severity = .low
            case 2: severity = .medium
            default: severity = .high
        }

        self.vibrate()
        self.clicks = 0
    
        // Foreground -> Show VC
        // Background -> Raise notification if in background
        let state = UIApplication.shared.applicationState
        if case .active = state {
            guard let _ = self.peripheral else { return }
            let vc = AlertViewController(alert: .keyringButton, severity: severity)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.createLocalNotification(alert: .keyringButton, severity: severity)
        }
    }

    // MARK: Notifications

    func checkIfDeviceSupportsAppBackgroundRefresh() {
        let app = UIApplication.shared
        let refreshStatus = app.backgroundRefreshStatus
        switch refreshStatus {
        case .available:
            print("Background refresh available")
        case .denied:
            print("Background refresh denied")
            self.showAlert("BackgroundRefresh.Denied".localized)
        case .restricted:
            print("Background refresh restricted e.g. parental mode")
        }
    }

    func createLocalNotification(alert: Alert, severity: Severity) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: 0)
        localNotification.alertBody = severity.notificationMessage(alert: alert)
        localNotification.timeZone = TimeZone.autoupdatingCurrent
        localNotification.userInfo = [
            "severity": severity.rawValue,
            "alert": alert.rawValue
        ]
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = alert.rawValue
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    func createLocalNotification(connected: Bool) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: 0)
        localNotification.alertBody = connected ? "KeyringButton.Connected".localized : "KeyringButton.Disconnected".localized
        localNotification.timeZone = TimeZone.autoupdatingCurrent
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.category = "connection"
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
}
