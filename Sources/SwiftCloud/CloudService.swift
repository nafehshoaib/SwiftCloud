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

open class CloudService<CloudURLKey, PathKey>: NSObject where CloudURLKey: CloudServerURL, PathKey: CloudServicePath {
    private enum KeychainKeys: String {
        case accessToken
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
    
    public var isLoggedIn: Bool {
        return accessToken != nil
    }
    
    open func request(at path: PathKey,
                 using method: URLRequest.HTTPMethod,
                 body: Data? = nil,
                 authorize: Bool = false) throws -> URLRequest {
        let urlString = serverURL.url.absoluteString + path.pathString
        
        var request = URLRequest(url: URL(string: urlString)!)
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
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    open func sendRequest(at path: PathKey,
                     using method: URLRequest.HTTPMethod,
                     body: Data? = nil,
                     authorize: Bool = false) async throws -> (Data, HTTPURLResponse) {
        let request = try request(at: path, using: method, body: body, authorize: authorize)
        
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
