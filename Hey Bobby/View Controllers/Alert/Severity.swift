//
//  Severity.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 19/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import Foundation
import DefaultsKit
import UIKit

public enum Severity: String {
    case low
    case medium
    case high

    var color: UIColor {
        switch self {
        case .low:
            return .alertLowColor
        case .medium:
            return .alertMediumColor
        case .high:
            return .alertHighColor
        }
    }

    func alertMessage(alert: Alert) -> String {
        switch self {
        case .low: return Defaults.shared.get(for: Keys.KeyringButtonLowMessage) ?? "KeyringButtonsSetup.Low.DefaultValue".localized
        case .medium: return Defaults.shared.get(for: Keys.KeyringButtonMediumMessage) ?? "KeyringButtonsSetup.Medium.DefaultValue".localized
        case .high: return Defaults.shared.get(for: Keys.KeyringButtonHighMessage) ?? "KeyringButtonsSetup.High.DefaultValue".localized
        }
    }
    
    func notificationMessage(alert: Alert) -> String {
        switch self {
        case .low: return Defaults.shared.get(for: Keys.KeyringButtonLowMessage) ?? "KeyringButtonsSetup.Low.DefaultValue".localized
        case .medium: return Defaults.shared.get(for: Keys.KeyringButtonMediumMessage) ?? "KeyringButtonsSetup.Medium.DefaultValue".localized
        case .high: return Defaults.shared.get(for: Keys.KeyringButtonHighMessage) ?? "KeyringButtonsSetup.High.DefaultValue".localized
        }
    }
}
