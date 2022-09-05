//
//  CloudError.swift
//
//
//  Created by Nafeh Shoaib on 8/13/22.
//

import Foundation
import SwiftyJSON

public enum CloudError: Error, LocalizedError {
    case httpError(Data, HTTPURLResponse), unknownError, unauthorized
    
    public var errorDescription: String? {
        switch self {
        case let .httpError(data, response):
            return "Error code: \(response.statusCode) with data: \(JSON(data))."
        case .unauthorized:
            return "Unauthorized request: Access Token is invalid"
        default:
            return "Unknown Error (non HTTP) occurred."
        }
    }
}
