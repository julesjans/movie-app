//
//  APIClient.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import Foundation
import UIKit.UIImage

// MARK: - APIAccessible

/**
 APIAccessible protocol.
 Classes that conform to this protocol can be accessed using an APIClient.
 */
protocol APIAccessible {
    init?(dict: [String: Any])
    /**
     GET Request for data. Dependency injection of APIClient to enable testing.
     - parameter id: String id/search term for request.
     - parameter api: The APIClient to use.
     - parameter completion: Completion block with success status, item of APIAccessible, or APIError.
     */
    static func get(id: Int, api: APIClient, completion: @escaping (Self?, APIError?) -> Void)
}

extension APIAccessible {
    
    static func get(id: Int, api: APIClient, completion: @escaping (Self?, APIError?) -> Void) {
        api.get(urlString: "\(String(describing: Self.self).lowercased())/\(id)", completion: completion)
    }
    
    /// Creates an array of APIAcessible from an array of dictionaries
    static func from(array: Array<[String: Any]>) -> [Self] {
        return array.compactMap { Self(dict: $0) }
    }
    
}

// MARK: - APIClient

/**
 APIClient protocol.
 Classes that conform to this protocol can be used to fetch APIAccessible items.
 */
protocol APIClient {
    /**
     GET Request for data using generic types.
     - parameter urlString: Specific url for resource.
     - parameter completion: Completion block with success status, array of APIAccessibles, or APIError
     */
    func get<T:APIAccessible>(urlString: String, completion: @escaping (T?, APIError?) -> Void)
    
    /**
     GET Request for images using URLSession download task
     - parameter for: Specific url for resource.
     - parameter completion: Completion block with original url string, UIImage, or APIError
     */
    func image(for pathString: String, completion: @escaping (String, UIImage?, APIError?) -> Void)
}

struct APIError: Error {
    let statusCode: Int?
    let statusMessage: String?
}

// MARK: - Live API
final class APIClientLive: APIClient {

    func get<T:APIAccessible>(urlString: String, completion: @escaping (T?, APIError?) -> Void) {

        var query = URLComponents(string: "https://api.themoviedb.org/3/\(urlString)")
        var queries = [URLQueryItem]()
        query?.queryItems?.forEach {queries.append($0)}
        let apiKey = URLQueryItem(name: "api_key", value: APICredentials.key)
        queries.append(apiKey)
        query?.queryItems = queries
        
        guard let url = query?.url else {
            assertionFailure("Invalid API URL")
            return
        }

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            guard error == nil else {
                completion(nil, APIError(statusCode: nil, statusMessage: error!.localizedDescription))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, APIError(statusCode: nil, statusMessage: "No valid response"))
                return
            }
            
            guard response.statusCode == 200  else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let dictionary = json as! [String: Any]
                    completion(nil, APIError(statusCode: response.statusCode, statusMessage: "\(dictionary["status_message"]!)"))
                }
                catch {
                    completion(nil, APIError(statusCode: response.statusCode, statusMessage: "Unable to process that request"))
                }
                return
            }
        
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let dictionary = json as! [String: Any]
                completion(T(dict: dictionary), nil)
            }
            catch {
                completion(nil, APIError(statusCode: response.statusCode, statusMessage: "Unable to process that request"))
            }
        }
        task.resume()
    }
    
    func image(for pathString: String, completion: @escaping (String, UIImage?, APIError?) -> Void) {
        
        if let data = try? AssetCache.read(name: pathString) {
            completion(pathString, UIImage(data: data), nil)
            return
        }
        
        let query = URLComponents(string: "https://image.tmdb.org/t/p/w500\(pathString)")
        guard let requestUrl = query?.url else {
            assertionFailure("Invalid URL")
            return
        }
        let task = URLSession.shared.downloadTask(with: URLRequest(url: requestUrl)) { (fileUrl, response, error) in
            guard error == nil, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                completion(pathString, nil, APIError(statusCode: statusCode, statusMessage: error?.localizedDescription ?? "Response error"))
                return
            }
            if let download = fileUrl {
                if let data = try? Data(contentsOf: download) {
                    completion(pathString, UIImage(data: data), nil)
                    try? AssetCache.write(data: data, name: pathString)
                    return
                }
            }
        }
        task.resume()
    }

}

// MARK: - Mock API, for use in tests
final class APIClientMock: APIClient {
    
    func get<T>(urlString: String, completion: @escaping (T?, APIError?) -> Void) where T : APIAccessible {
        let bundle = Bundle.main
        
        let fileName: String!
      
        switch T.self {
        case is Movie.Type where ["movie/954", "movie/353081", "movie/351286"].contains(urlString):
            fileName = urlString.replacingOccurrences(of: "/", with: "")
        case is Movie.Type:
            fileName = "movie353081"
        case is Genre.Type:
            fileName = "genre"
        case is MovieCollection.Type:
            fileName = "collection"
        default:
            fileName = "now_playing"
        }
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let rawSuccessData = json as! [String: Any]
        completion(T(dict: rawSuccessData), nil)
    }
    
    func image(for pathString: String, completion: @escaping (String, UIImage?, APIError?) -> Void) {
        completion(pathString, UIImage(named: "image.jpg"), nil)
    }
    
}
