//
//  URLRequest+HTTPMethod.swift
//
//
//  Created by Nafeh Shoaib on 8/16/21.
//

import Foundation

extension URLRequest {
    public enum HTTPMethod: String {
        case put = "PUT"
        case post = "POST"
        case get = "GET"
        case delete = "DELETE"
        case head = "HEAD"
    }
}
