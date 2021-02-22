//
//  File.swift
//  
//
//  Created by E0102 on 10/02/21.
//

import Foundation

extension UInt64 {
    /// Data from UInt64
    var data: Data {
        var int = self
        let intData = Data(bytes: &int, count: MemoryLayout.size(ofValue: self))
        return intData
    }
}
