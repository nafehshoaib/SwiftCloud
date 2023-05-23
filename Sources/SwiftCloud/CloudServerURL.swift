//
//  CloudServerURL.swift
//
//
//  Created by Nafeh Shoaib on 8/13/22.
//

import Foundation

import WebURL

public protocol CloudServerURL {
    var urlString: String { get }
    var url: URL { get }
    var safeString: String { get }
    var webURL: WebURL? { get }
}

public protocol CloudServerURLRepresentable: CloudServerURL, RawRepresentable { }

extension CloudServerURL {
    public var url: URL {
        return URL(string: safeString)!
    }
    
    public var safeString: String {
        return urlString.last == "/" ? urlString : urlString + "/"
    }
    
    public var webURL: WebURL? {
        return WebURL(safeString)
    }
}

extension CloudServerURLRepresentable where RawValue == String {
    public var urlString: String {
        return rawValue
    }
}
