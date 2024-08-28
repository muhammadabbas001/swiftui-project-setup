//
//  NetworkManager.swift
//  Fryends (iOS)
//
//  Created by Muhammad Abbas on 5/24/22.
//

import Combine
import Foundation
import Network
import SwiftUI
import Swinject

/// enum for the media type object, currently there will be photo or video.
enum MediaType: String {
    case photo = "image/jpeg"
    case video = "video/mp4"
    
    func getTarget() -> String{
        switch self {
        case .photo:
            return "profileImage"
        case .video:
            return "profileVideo"
        }
    }
    
    func getFileName() -> String{
        switch self {
        case .photo:
            return "ImageFile\(Int(Date().timeIntervalSince1970)).jpg"
        case .video:
            return "VideoFile\(Int(Date().timeIntervalSince1970)).mp4"
        }
    }
}

/// A media struct which is being used to pass in multipart request with some properties.
struct Media {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    let isCover: Bool
    init?(withMediaData data: Data, forKey key: String, withMimeType mediaType: MediaType, isCover: Bool) {
        self.key = key
        self.mimeType = mediaType.rawValue
        if mediaType == .photo {
            self.filename = "ImageFile\(Date()).jpg"
        } else {
            self.filename = "VideoFile\(Date()).mp4"
        }
        self.data = data
        self.isCover = isCover
    }
}

/// Handles all network calls mad by the app
class NetworkManager {
    
    // Set global logger object
    static let netlogger = Logger()
    
    /// Use this method to call your desired endpoint
    ///
    /// - Parameters:
    ///  - endpoint: The desired endpoint that will be used to make this call
    ///  - dataType: The data type you will expect back from the call (Optional, as all calls will not have a data type to send back
    static func makeEndpointCall<T: Decodable>(fromEndpoint endpoint: NetworkConstants.Endpoint,
                                               withDataType dataType: T.Type? = nil,
                                               parameters: [String: Any]? = nil,
                                               mediaData: Media? = nil,
                                               promise: @escaping (Result<T, Error>) -> ()) {
        
        NetworkManager.endpointCall(endpoint: endpoint,
                                    parameters: parameters,
                                    mediaData: mediaData,
                                    dataType: dataType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    logger.info("Endpoint call is complete: \(completion)", category: .network)
                case .failure(let error):
                    logger.error("Endpoint call has an error: \(error)", category: .network)
                    promise(.failure(error))
                }
            }, receiveValue: { value in
                promise(.success(value))
            })
            .store(in: &cancelables)
        
    }
    
    // MARK: - Private
    
    /// This counter is for how many times a refresh should happen: [n = n+1 times]
    private static var refreshAttempts = 2
    private static var cancelables = Set<AnyCancellable>()
    private static let baseURL: String = NetworkConstants.ProductDefinition.BaseAPI.development.rawValue
    private static var userAuthenticationManager = Container.default.resolver.resolve(UserAuthenticationManager.self)
    
    /// Main endpoint call that handles multiple endpoint strings and http request configurations
    ///
    /// - Parameters:
    ///  - endpoint: The desired endpoint that will be used to make this call
    ///  - parameters: Values that the endpoint may need to configure the call or may need to send (Optional)
    ///  - urlParameter: A single value that will be attached to an endpoint such as an 'id' (This may not be needed anymore)
    ///  - dataType: The data type you will expect back from the call (Optional, as all calls will not have a data type to send back
    private static func endpointCall<T: Decodable>(endpoint: NetworkConstants.Endpoint,
                                                   parameters: [String: Any]? = nil,
                                                   urlParameter: String? = nil,
                                                   mediaData: Media? = nil,
                                                   dataType: T.Type? = nil) -> Future<T, Error> {
        
        // Check for reachability just before the call is made
        checkReachability()
        
        return Future<T, Error> { promise in
            
            guard var url = URLComponents(string: self.baseURL.appending(endpoint.value)) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            let request = setUrlRequest(url: &url,
                                        parameters: parameters,
                                        mediaData: mediaData,
                                        endpoint: endpoint)
            logger.debug("URL is \(url.url?.absoluteString ?? "")", category: .network)
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        
                        // Send sentry alert when there is a significant network error
                        let statusCode = (response as? HTTPURLResponse)?.statusCode
                        let fullFailureMessage = "Failed with \(response.description) while making endpoint call \(endpoint.value). The network failure status code is: \(String(describing: statusCode))"
                        // logs
                        logger.error(fullFailureMessage, category: .network)
                        
                        print("Response: ---")
                        print(String(data: data, encoding: .utf8))
                        
                        if statusCode == 500 {
                            promise(.failure(NetworkError.serverError))
                            throw NetworkError.serverError
                        } else {
                            /// get request error that are defined on BE.
                            do {
                                let decodedData = try JSONDecoder().decode(RequestErrorModel.self, from: data)
                                // Backend sends this string instead of error code for retrieving Skillr with invalid ID
                                if decodedData.errorcode == "No such skillr" {
                                    logger.error("Error with status code 'no such Skillr'", category: .network)
                                    throw RequestError(message: "NetworkErrorCodes.Skillr.NoSuchSkillr")
                                } else if decodedData.errorcode == nil && decodedData.name == "RateLimitError" {
                                    throw RequestError(message: "NetworkErrorCodes.User.rateLimit")
                                }
                                throw RequestError(message: decodedData.message)
                            }
                        }
                        throw NetworkError.unknown
                    }
                    
                    /// - Note: Testing log. Commented out to declutter console
                     parseTest(fromData: data)
                    
                    print("Response: ---")
                    print(String(data: data, encoding: .utf8))
                    
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            logger.error("There has been a DecodingError from \(#function) with code \(decodingError.localizedDescription)", category: .network)
                            promise(.failure(decodingError))
                        case let networkError as NetworkError:
                            
                            /// - Note: This cannot be removed although it seems like it does nothing. Removing it will not execute the full total recall for some reason and needs to be looked into more
                            
                            logger.error("There has been a NetworkError from \(#function), with error: \(String(describing: networkError.errorDescription))", category: .network)
                            
                            // get error code value
                            let errorCode = (error as NSError).code
                            logger.debug("The error code is: \(errorCode)", category: .network)
                            
                            /// - Note: if this is here it will kill whatever comes back from the original total recall from the unauth code. Keeping it here for reference
                            promise(.failure(NetworkError.unknown))
                        case let requestError as RequestError:
                            logger.error("There has been a RequestError from \(#function) with code \(requestError.code)", category: .network)
                            promise(.failure(requestError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                    
                }, receiveValue: {
                    logger.info("Value was returned successfully from network call.", category: .network)
                    promise(.success($0))
                })
                .store(in: &self.cancelables)
            
        }
    }
    
    /// Set the HTTP (request) method by the endpoint being used
    ///
    /// - Parameters:
    ///  - endpoint: The endpoint needed to determine what request method gets returned
    ///
    /// - Returns: HTTP request method
    private static func setRequestMethod(forEndpoint endpoint: NetworkConstants.Endpoint) -> NetworkConstants.RequestMethod {
        switch endpoint {
            
        case .retrieveSkillrList:
            return .get
            
        case .login,
             .refreshToken:
            return .post
        }
        
        
    }
    /// - Note: May need to build a method (or add to the one above to return a tuple) for default parameter settings
    
    /// Set the URL request that will be used by the endpoint call method
    ///
    ///  - Parameters:
    ///   - url: The URL component that will be set
    ///   - parameters: Values that will be added (optional)
    ///   - endpoint: Used to determine what HTTP request method will be used
    private static func setUrlRequest(url: inout URLComponents,
                                      parameters: [String: Any]? = nil,
                                      mediaData: Media? = nil,
                                      endpoint: NetworkConstants.Endpoint) -> URLRequest {
        
        var request = URLRequest(url: url.url ?? URL(fileURLWithPath: ""))
        request.httpMethod = setRequestMethod(forEndpoint: endpoint).rawValue
        let boundary = generateBoundary()
        
        // Get current token for testing on postman, etc. Keep this commented out unless needed
        logger.info("Current jwt: \(UserDefaults.standard.jwt ?? "")", category: .lifecycle)
        
        if endpoint.includeBearerToken {
            request.setValue("Bearer \(UserDefaults.standard.jwt ?? "")", forHTTPHeaderField: "Authorization")
        }
        if mediaData != nil {
            //set content type
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        }
        else {
            request.setValue(NetworkConstants.HeaderContentType.Value.applicationJSON.rawValue, forHTTPHeaderField: "Content-Type")
            request.setValue(NetworkConstants.HeaderContentType.Value.applicationJSON.rawValue, forHTTPHeaderField: "Accept")
        }
        
        if let realParams = parameters {
            
            if request.httpMethod == NetworkConstants.RequestMethod.post.rawValue ||
                request.httpMethod == NetworkConstants.RequestMethod.put.rawValue {
                
                // set to httpBody (for POST)
                if mediaData != nil {
                    let dataBody = createDataBody(withParameters: parameters, media: mediaData, boundary: boundary)
                    request.httpBody = dataBody
                } else {
                    let paramData = try? JSONSerialization.data(withJSONObject: realParams, options: .prettyPrinted)
                    request.httpBody = paramData
                }
            } else {
                
                // add to query items way (for not POST)
                var components = URLComponents(string: url.url?.absoluteString ?? "")
                
                components?.queryItems = realParams.map { (key, value) in
                    URLQueryItem(name: key, value: value as? String)
                }
                let replacingPlus = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
                components?.percentEncodedQuery = replacingPlus
                request = URLRequest(url: components?.url ?? URL(fileURLWithPath: "") )
            }
        }
        if mediaData != nil {
            let dataBody = createDataBody(withParameters: parameters, media: mediaData, boundary: boundary)
            request.httpBody = dataBody
        }
        
        return request
        
    }
    
    /// Upload image/video on S3 bucket
    /// - Parameters:
    ///   - uploadURL: url for network request
    ///   - httpBody: image/video data directly assign to body
    ///   - mediaType: type image/video
    ///   - completion: Successfully uploaded the image/video or not
    /// - Note: When we upload the image/video to the S3 then empty data return which is not decoding, that's why we use a separate request for that till we will find a solution
    static func uploadImageOrVideo(_ uploadURL: String, _ httpBody: Data, _ mediaType: MediaType, completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: URL(string: uploadURL)!, timeoutInterval: Double.infinity)
        request.addValue(mediaType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error{
                completion(false)
            }else{
                completion(true)
            }
        }
        task.resume()
    }
    
    /// A local test method to see raw JSON data
    private static func parseTest(fromData data: Data) {
        
        do {
            
            guard let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] else {
                guard let parsedResult2 = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String:AnyObject]] else { return }
                print(parsedResult2)
                logger.info("Parse test successful: \(parsedResult2)", category: .network)
                return
            }
            
            print(parsedResult)
            logger.info("Parse test successful: \(parsedResult)", category: .network)
        } catch {
            logger.error("Could not parse the data as JSON: '\(String(describing: data))'", category: .network)
            return
        }
    }
    
    /// Recall entire API method only after a refresh token has been used to replace an expired jwt.
    ///  - Parameters: The same as the method [makeEndpointCall]
    ///  - Returns: Type requested and error if there is one
    private static func totalRecall<T: Decodable>(endpoint: NetworkConstants.Endpoint,
                                                  parameters: [String: Any]? = nil,
                                                  mediaData: Media? = nil,
                                                  dataType: T.Type? = nil,
                                                  recalled: @escaping(_ : Bool, _ : T?, _ : Error?) -> Void) {
        
        NetworkManager.endpointCall(endpoint: endpoint,
                                    parameters: parameters,
                                    mediaData: mediaData,
                                    dataType: dataType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    print("")
                case .failure(let error):
                    recalled(false, NilModel.self as? T, error)
                }
                
            }, receiveValue: { value in
                recalled(true, value, nil)
            })
            .store(in: &cancelables)
        
    }
    
    // MARK: End refresh -
    
    /// func to create data and param body for multipart request.
    private static func createDataBody(withParameters params: [String: Any]?, media: Media?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        let body = NSMutableData()
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value as! String + lineBreak)")
            }
        }
        
        if media?.isCover == true{
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"cover\"\(lineBreak + lineBreak)")
            body.append("\((media?.isCover)!)\(lineBreak)")
        }
        
        if let media = media {
            /// loop in case we need an array later
            //      for photo in media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.filename)\"\(lineBreak)")
            body.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)")
            body.append(media.data)
            body.append(lineBreak)
            //      }
        }
        body.append("--\(boundary)--\(lineBreak)")
        return body as Data
    }
    
    private static func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    // MARK: - Reachability
    
    /// Here is where the apps reachability will be checked before an API call is ran
    private static func checkReachability() {
        
    }
}

extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
