//
//  AssetCache.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2017 Julian Jans. All rights reserved.
//

import Foundation

struct AssetCache {
    
    private static var storageLocation: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("Assets")
    }
    
    private static func sanitized(name: String) -> String {
        return name.replacingOccurrences(of: "/", with: "")
    }

    static func clear() throws {
        try FileManager.default.removeItem(at: storageLocation)
    }
    
    static func read(name: String) throws -> Data {
        let url = storageLocation.appendingPathComponent("\(sanitized(name: name))")
        return try Data(contentsOf: url)
    }
    
    static func write(data: Data, name: String) throws {
        let url = storageLocation.appendingPathComponent("\(sanitized(name: name))")
        try FileManager.default.createDirectory(at: storageLocation, withIntermediateDirectories: true, attributes: nil)
        try data.write(to: url, options: .atomicWrite)
    }
    
}
