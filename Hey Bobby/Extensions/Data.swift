//
//  Data.swift
//  Hey Bobby
//
//  Created by Akram Hussein on 23/10/2017.
//  Copyright © 2017 Akram Hussein. All rights reserved.
//

import Foundation

extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
