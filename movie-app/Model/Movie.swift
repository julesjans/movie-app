//
//  Road.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import Foundation

final class Movie {
        
    var id: Int
    var title: String
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var genres: [Genre]?
    var collection: MovieCollection?
    
    required init?(dict: [String: Any]) {
        
        guard dict["id"] is Int, dict["title"] is String else {
            assertionFailure()
            return nil
        }
        
        id = dict["id"] as! Int
        title = dict["title"] as! String
        posterPath = dict["poster_path"] as? String
        backdropPath = dict["backdrop_path"] as? String
        voteAverage = dict["vote_average"] as? Double
        voteCount = dict["vote_count"] as? Int
        if let genreArray = dict["genres"] as? [[String: Any]] {
            genres = Genre.from(array: genreArray)
        }
        if let collectionDict = dict["belongs_to_collection"] as? [String: Any] {
            collection = MovieCollection(dict: collectionDict)
        }
        
    }
    
}

extension Movie: APIAccessible {
    
    static func get(id: Int?, api: APIClient, completion: @escaping (Movie?, APIError?) -> Void) {
        guard let id = id else {
            assertionFailure()
            return
        }
        api.get(urlString: "movie/\(id)", completion: completion)
    }
    
}

