//
//  NetworkErrors.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/24/22.
//
// MARK: - All network error codes and references will be placed here

import Combine
import Foundation


/// Error model to send complete error information
struct RequestError: Error {
    let code: Int? = nil
    let message: String?
}

struct RequestErrorModel: Codable {
    let name: String?
    let message: String?
    let errorcode: String?
    let errors: [String]?
}


enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
    case serverError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Something went wrong", comment: "Unknown error")
        case .serverError:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}
