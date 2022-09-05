//
//  Keychain+Subscript.swift
//  
//
//  Created by Nafeh Shoaib on 9/5/22.
//

import Foundation
import KeychainAccess

extension Keychain {
    public subscript<Key>(_ key: Key) -> String? where Key: RawRepresentable, Key.RawValue == String {
        get {
            self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}
