//
//  CloudService.swift
//
//
//  Created by Nafeh Shoaib on 8/13/22.
//

import Foundation
import os

import KeychainAccess
import SwiftDate
import WebURL
import WebURLFoundationExtras

open class CloudService<CloudURLKey, PathKey>: NSObject where CloudURLKey: CloudServerURL, PathKey: CloudServicePath {
    private enum KeychainKeys: String {
        case accessToken, refreshToken
    }
    
    private lazy var keychain: Keychain = {
        return Keychain(
            server: serverURL.safeString,
            protocolType: .https
        )
        .synchronizable(true)
    }()
    
    var serverURL: CloudURLKey
    
    public init(serverURL: CloudURLKey) {
        self.serverURL = serverURL
    }
    
    private var accessToken: String? {
        get {
            return keychain[KeychainKeys.accessToken]
        }
        set {
            keychain[KeychainKeys.accessToken] = newValue
        }
    }
    
    public var refreshToken: String? {
        get {
            return keychain[KeychainKeys.refreshToken]
        }
        set {
            keychain[KeychainKeys.refreshToken] = newValue
        }
    }
    
    public var isLoggedIn: Bool {
        return accessToken != nil
    }
    
    open func request(at path: PathKey,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json,
                      authorize: Bool = false) throws -> URLRequest {
        return try request(at: path.pathString,
                           using: method,
                           body: body,
                           contentType: contentType,
                           authorize: authorize)
    }
    
    open func request(webURL: WebURL,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json,
                      authorize: Bool = false) throws -> URLRequest {
        var request = URLRequest(url: webURL)
        request.httpMethod = method.rawValue
        
        if authorize {
            if let accessToken = accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw CloudError.unauthorized
            }
        }
        
        if let body = body {
            request.httpBody = body
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    open func request(at pathString: String,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json,
                      authorize: Bool = false) throws -> URLRequest {
        guard var webURL = serverURL.webURL else {
            throw CloudError.invalidURL(serverURL.urlString, pathString)
        }
        
        webURL.pathComponents.append(pathString)
        
        return try request(webURL: webURL, using: method, body: body, contentType: contentType, authorize: authorize)
    }
    
    open func sendRequest(at path: PathKey,
                          using method: URLRequest.HTTPMethod,
                          body: Data? = nil,
                          contentType: CloudContentType = .json,
                          authorize: Bool = false) async throws -> (Data, HTTPURLResponse) {
        return try await sendRequest(at: path.pathString,
                                     using: method,
                                     body: body,
                                     contentType: contentType,
                                     authorize: authorize)
    }
    
    open func sendRequest(at pathString: String,
                          using method: URLRequest.HTTPMethod,
                          body: Data? = nil,
                          contentType: CloudContentType = .json,
                          authorize: Bool = false) async throws -> (Data, HTTPURLResponse) {
        let request = try request(at: pathString, using: method, body: body, contentType: contentType, authorize: authorize)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300 {
                return (data, httpResponse)
            } else if httpResponse.statusCode == 401 {
                self.setAccessToken(nil)
            }
            
            throw CloudError.httpError(data, httpResponse)
        }
        
        throw CloudError.unknownError
    }
    
    open func setAccessToken(_ token: String?) {
        self.accessToken = token
    }
}
