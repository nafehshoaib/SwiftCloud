//
//  CloudServicePath.swift
//  HumineiOSMVP
//
//  Created by Nafeh Shoaib on 9/3/22.
//

import Foundation

public protocol CloudServicePath {
    var pathString: String { get }
}

public protocol CloudServicePathRepresentable: CloudServicePath, RawRepresentable { }

extension CloudServicePathRepresentable where RawValue == String {
    public var pathString: String {
        return rawValue
    }
}
