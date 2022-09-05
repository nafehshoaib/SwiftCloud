//
//  CloudServerURL.swift
//
//
//  Created by Nafeh Shoaib on 8/13/22.
//

import Foundation

public protocol CloudServerURL {
    var urlString: String { get }
    var url: URL { get }
    var safeString: String { get }
}

public protocol CloudServerURLRepresentable: CloudServerURL, RawRepresentable { }

extension CloudServerURL {
    public var url: URL {
        return URL(string: safeString)!
    }
    
    public var safeString: String {
        return urlString.last == "/" ? urlString : urlString + "/"
    }
}

extension CloudServerURLRepresentable where RawValue == String {
    public var urlString: String {
        return rawValue
    }
}
