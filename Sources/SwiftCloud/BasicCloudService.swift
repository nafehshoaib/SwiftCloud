//
//  BasicCloudService.swift
//
//
//  Created by Nafeh Shoaib on 11/28/23.
//

import Foundation

import KeychainAccess
import SwiftDate
import WebURL
import WebURLFoundationExtras

open class BasicCloudService<CloudURLKey, PathKey>: NSObject where CloudURLKey: CloudServerURL, PathKey: CloudServicePath {
    
    var serverURL: CloudURLKey
    
    public init(serverURL: CloudURLKey) {
        self.serverURL = serverURL
    }
    
    open func request(at path: PathKey,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json) throws -> URLRequest {
        return try request(at: path.pathString,
                           using: method,
                           body: body,
                           contentType: contentType)
    }
    
    open func request(webURL: WebURL,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json) throws -> URLRequest {
        var request = URLRequest(url: webURL)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = body
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    open func request(at pathString: String,
                      using method: URLRequest.HTTPMethod,
                      body: Data? = nil,
                      contentType: CloudContentType = .json) throws -> URLRequest {
        guard let webURL = serverURL.webURL?.set(path: pathString) else {
            throw CloudError.invalidURL(serverURL.urlString, pathString)
        }
        
        return try request(webURL: webURL, using: method, body: body, contentType: contentType)
    }
    
    open func sendRequest(at path: PathKey,
                          using method: URLRequest.HTTPMethod,
                          body: Data? = nil,
                          contentType: CloudContentType = .json) async throws -> (Data, HTTPURLResponse) {
        return try await sendRequest(at: path.pathString,
                                     using: method,
                                     body: body,
                                     contentType: contentType)
    }
    
    open func sendRequest(at pathString: String,
                          using method: URLRequest.HTTPMethod,
                          body: Data? = nil,
                          contentType: CloudContentType = .json) async throws -> (Data, HTTPURLResponse) {
        let request = try request(at: pathString, using: method, body: body, contentType: contentType)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 300 {
                return (data, httpResponse)
            } else if httpResponse.statusCode == 401 {
                throw CloudError.unauthorized
            }
            
            throw CloudError.httpError(data, httpResponse)
        }
        
        throw CloudError.unknownError
    }
}
