//
//  KeyringButtonsSetupViewController.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import UIKit
import Eureka
import DefaultsKit

final class KeyringButtonsSetupViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .primaryColor
        self.title = "KeyringButtonsSetup.Title".localized

        self.tableView.backgroundColor = .primaryColor
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none

        self.navigationItem.rightBarButtonItem = .textBarButton("Save".localized,
                                                                delegate: self,
                                                                action: #selector(self.saveButtonPressed(_:)),
                                                                color: .white)

        TextAreaRow.defaultCellSetup = { cell, _ in
            cell.backgroundColor = .primaryColor
            cell.textLabel?.textColor = .white
            cell.textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            cell.textView.tintColor = .white
        }

        ButtonRow.defaultCellUpdate = { cell, _ in
            cell.backgroundColor = .primaryColor
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 19.0)
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView?.tintColor = .white
        }
        
        self.form +++ Section("KeyringButtonsSetup.Low.Title".localized)

            <<< TextAreaRow("keyring_buttons_text_low") { row in
                row.title = "KeyringButtonsSetup.AlertMessage".localized
                row.value = Severity.low.alertMessage(alert: .keyringButton)
                row.placeholder = "KeyringButtonsSetup.Low.DefaultValue".localized
            }.cellUpdate { cell, _ in
                cell.textView.textColor = .white
                cell.textView.backgroundColor = .alertLowColor
            }

            +++ Section("KeyringButtonsSetup.Medium.Title".localized)

            <<< TextAreaRow("keyring_buttons_text_medium") { row in
                row.title = "KeyringButtonsSetup.AlertMessage".localized
                row.value = Severity.medium.alertMessage(alert: .keyringButton)
                row.placeholder = "KeyringButtonsSetup.Medium.DefaultValue".localized
            }.cellUpdate { cell, _ in
                cell.textView.textColor = .white
                cell.textView.backgroundColor = .alertMediumColor
            }

            +++ Section("KeyringButtonsSetup.High.Title".localized)

            <<< TextAreaRow("keyring_buttons_text_high") { row in
                row.title = "KeyringButtonsSetup.AlertMessage".localized
                row.value = Severity.high.alertMessage(alert: .keyringButton)
                row.placeholder = "KeyringButtonsSetup.High.DefaultValue".localized
            }.cellUpdate { cell, _ in
                cell.textView.textColor = .white
                cell.textView.backgroundColor = .alertHighColor
            }

    }

    @objc func saveButtonPressed(_ sender: Any) {
        guard let lowRow = self.form.rowBy(tag: "keyring_buttons_text_low") as? TextAreaRow else { return }
        if let low = lowRow.value { Defaults.shared.set(low, for: Keys.KeyringButtonLowMessage) }
        else { Defaults.shared.clear(Keys.KeyringButtonLowMessage) }

        guard let mediumRow = self.form.rowBy(tag: "keyring_buttons_text_medium") as? TextAreaRow else { return }
        if let medium = mediumRow.value { Defaults.shared.set(medium, for: Keys.KeyringButtonMediumMessage) }
        else { Defaults.shared.clear(Keys.KeyringButtonMediumMessage) }

        guard let highRow = self.form.rowBy(tag: "keyring_buttons_text_high") as? TextAreaRow else { return }
        if let high = highRow.value { Defaults.shared.set(high, for: Keys.KeyringButtonHighMessage) }
        else { Defaults.shared.clear(Keys.KeyringButtonHighMessage) }

        self.navigationController?.popViewController(animated: true)
    }
}
