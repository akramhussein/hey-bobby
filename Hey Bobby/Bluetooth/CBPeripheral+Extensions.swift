//
//  CBPeripheral+Extensions.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 23/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import Foundation
import CoreBluetooth

public extension CBPeripheral {
    public func getAllServicesFromPeripheral() {
        self.discoverServices(nil)
    }
    
    public func getAllCharacteristicsFromPeripheral() {
        let cbuuids = self.services!.map { $0.uuid }
        self.discoverServices(cbuuids)
    }
    
}

