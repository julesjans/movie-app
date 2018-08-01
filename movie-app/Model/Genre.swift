//
//  Genre.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import Foundation

final class Genre: APIAccessible {
        
    var id: Int
    var name: String

    required init?(dict: [String: Any]) {
        
        guard dict["id"] is Int, dict["name"] is String else {
            assertionFailure()
            return nil
        }
        
        id = dict["id"] as! Int
        name = dict["name"] as! String
    }

}
