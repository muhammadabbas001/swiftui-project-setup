//
//  NetworkConstants.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/24/22.
//

import Foundation
import Swinject

/// Constant values that will be used specifically for network calls and values
enum NetworkConstants {
    
    /// Keys for authenticated user token and backup refresh token
    enum AuthenticationKeys: String {
        case jwtKey = "jwtKey"
        case refreshJwtKey = "refreshJwtKey"
        case id = "idKey"
    }
    
    /// Product definition environment string constants
    struct ProductDefinition {
        static let appDomain = ""
        
        /// - Note: These will be toggled between 'staging' and 'prod' once the app is setup for multiple environments
        
        enum AppDomain: String {
            case prod = "com.fryends.app"
            case staging = "com.fryends.staging.app"
            case development = "com.fryends.development.app"
        }
        
        enum BaseAPI: String {
            case prod = "https://api-production.fryends.com/api"
            case staging = "https://api-staging.fryends.com/api"
            case development = "http://api.fryends.com/api"
        }
        
        static let deviceType = "ios"
        static let baseURL = ProductDefinition.BaseAPI.development.rawValue
    }
    
    /// Request method values to determine call type
    enum RequestMethod: String {
        case options = "OPTIONS"
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
        case trace = "TRACE"
        case connect = "CONNECT"
        case none = ""
    }
    
    /// API call request content type
    enum HeaderContentType {
        static let applicationContentTypeKey = "Content-Type"
        
        enum Value: String {
            case applicationJSON = "application/json"
            case webFormUrlEncoded = "application/x-www-form-urlencoded"
            case allValues = "application/json, text/plain, */*"
        }
    }
    
    /// Static request parameter keys
    enum RequestParamKey: String {
        case deviceToken
        case deviceType
    }
    
    /// API endpoints that will be used by the Network Manager
    enum Endpoint: CustomStringConvertible {
        
        // MARK: - Auth
        
        /// Refresh auth token that is either expired or invalid: [.../app/refreshtoken]
        case refreshToken
        /// Login
        case login
        /// Retrieve list of Skillrs in no order with optional params ie: ["page": 1, "limit": 100] ("/app/skillrs")
        case retrieveSkillrList(query: String?)
       
        /// Returns string values of the endpoint cases
        var value: String {
            switch self {
            case .refreshToken:
                return "/refreshToken"
            case .login:
                return "/login"
            case .retrieveSkillrList(query: let query):
                return "/app/skillrs\(query ?? "")"
            }
        }
        
        /// Description of each endpoint case
        var description: String {
            switch self {
            case .refreshToken:
                return "Referesh a token"
            case .login:
                return "Login to the app"
            case .retrieveSkillrList:
                return "Retrieve list of Skillrs in no order with optional params ie: ['page': 1, 'limit': 100] (/app/skillrs)"
            }
        }
        
        /// Let request method know to include bearer token in current endpoint call
        var includeBearerToken: Bool {
            switch self {
            case .refreshToken,
                 .login:
                return false
            case .retrieveSkillrList(query: let query):
                if (query?.contains("isFavourite=true") ?? false) {
                    return true
                }
                return false
            default:
                return true
            }
        }
    }
    
}
