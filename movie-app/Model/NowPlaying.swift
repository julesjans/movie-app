//
//  NowPlaying.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import Foundation

final class NowPlaying {
    
    var page: Int
    var totalPages: Int
    var totalResults: Int
    var movies: [Movie]
    
    required init?(dict: [String: Any]) {
        
        guard [dict["page"], dict["total_pages"], dict["total_results"]] is [Int], dict["results"] is [[String: Any]] else {
            assertionFailure()
            return nil
        }
        
        page = dict["page"] as! Int
        totalPages = dict["total_pages"] as! Int
        totalResults = dict["total_results"] as! Int
        movies = Movie.from(array: (dict["results"] as! [[String: Any]]))
    }
    
}

extension NowPlaying: APIAccessible {

    static func get(id: Int?, api: APIClient, completion: @escaping (NowPlaying?, APIError?) -> Void) {
        var urlString = "movie/now_playing"
        if let id = id {urlString.append("?page=\(id)")}
        api.get(urlString: urlString, completion: completion)
    }
    
}
