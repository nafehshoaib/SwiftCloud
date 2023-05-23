//
//  WebURL+Declarative.swift
//  
//
//  Created by Nafeh Shoaib on 5/22/23.
//

import Foundation

import WebURL

import UsefulSwift

extension WebURL {
    public func set(scheme: String) -> Self {
        var s = self
        s.scheme = scheme
        return s
    }
    
    public func set(username: String?) -> Self {
        var s = self
        s.username = username
        return s
    }
    
    public func set(password: String?) -> Self {
        var s = self
        s.password = password
        return s
    }
    
    public func set(hostname: String?) -> Self {
        var s = self
        s.hostname = hostname
        return s
    }
    
    public func set(port: Int?) -> Self {
        var s = self
        s.port = port
        return s
    }
    
    public func set(path: String) -> Self {
        var s = self
        s.path = path
        return s
    }
    
    public func set(query: String?) -> Self {
        var s = self
        s.query = query
        return s
    }
    
    public func set(fragment: String?) -> Self {
        var s = self
        s.fragment = fragment
        return s
    }
    
    public func add(pathComponents: [String]) -> Self {
        var s = self
        s.pathComponents += pathComponents
        return s
    }
    
    public func addPathComponents(@ArrayBuilder<String> pathComponents: () -> [String]) -> Self {
        return add(pathComponents: pathComponents())
    }
    
    public func add(formParams: [(String, String)]) -> Self {
        var s = self
        s.formParams += formParams
        return s
    }
    
    public func addFormParams(@ArrayBuilder<(String, String)> formParams: () -> [(String, String)]) -> Self {
        return add(formParams: formParams())
    }
    
    public func add(formParams: [String: String]) -> Self {
        return add(formParams: formParams.map { ($0, $1) })
    }
    
    public func transform(_ transform: (Self) -> WebURL) -> WebURL {
        return transform(self)
    }
    
    public var string: String {
        return String(self.serialized())
    }
    
    public func set(path: some CloudServicePath) -> Self {
        return set(path: path.pathString)
    }
}
