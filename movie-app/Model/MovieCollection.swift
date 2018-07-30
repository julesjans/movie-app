//
//  Collection.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import Foundation

final class MovieCollection {
        
    var id: Int
    var name: String
    var posterPath: String?
    var backdropPath: String?
    var movies: [Movie]?
    
    required init?(dict: [String: Any]) {
        
        guard dict["id"] is Int, dict["name"] is String else {
            assertionFailure()
            return nil
        }

        id = dict["id"] as! Int
        name = dict["name"] as! String
        posterPath = dict["poster_path"] as? String
        backdropPath = dict["backdrop_path"] as? String
        if let moviesArray = dict["parts"] as? [[String: Any]] {
            movies = Movie.from(array:moviesArray)
        }
        
    }
    
}

extension MovieCollection: APIAccessible {
    
    static func get(id: Int?, api: APIClient, completion: @escaping (MovieCollection?, APIError?) -> Void) {
        guard let id = id else {
            assertionFailure()
            return
        }
        api.get(urlString: "collection/\(id)", completion: completion)
    }
    
}

