//
//  movie_appTests.swift
//  movie-appTests
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import XCTest
@testable import movie_app

class movie_appTests: XCTestCase {
    
    // Switch to testing the live API, although ratings etc may not pass!
    // var apiClient = APIClientLive()
    var apiClient = APIClientMock()
    
    func testNowPlayingFromAPI() {
        let promise = expectation(description: "testNowPlayingFromAPI")
        NowPlaying.get(id: nil, api: apiClient) { (nowPlaying, error) in
            XCTAssert(nowPlaying?.page == 1)
            XCTAssert(nowPlaying?.totalPages != nil)
            XCTAssert(nowPlaying?.totalResults != nil)
            XCTAssert(!(nowPlaying?.movies.isEmpty)!)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMovieFromAPI() {
        let promise = expectation(description: "testMovieFromAPI")
        Movie.get(id: 578, api: apiClient) { (movie, error) in
            XCTAssert(movie?.id == 578)
            XCTAssert(movie?.title == "Jaws")
            XCTAssert(movie?.posterPath == "/l1yltvzILaZcx2jYvc5sEMkM7Eh.jpg")
            XCTAssert(movie?.backdropPath == "/uTVuKo6OTGiead1ncsfH2klqYHC.jpg")
            XCTAssert(movie?.voteAverage == 7.6)
            XCTAssert(movie?.voteCount == 3737)
            XCTAssert(movie?.genres!.count == 3)
            XCTAssert(movie?.collection?.name == "The Jaws Collection")
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGenreFromAPI() {
        let promise = expectation(description: "testGenreFromAPI")
        Genre.get(id: 12, api: apiClient) { (genre, error) in
            XCTAssert(genre?.id == 12)
            XCTAssert(genre?.name == "Adventure")
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMovieCollectionFromAPI() {
        let promise = expectation(description: "testMovieCollectionFromAPI")
        MovieCollection.get(id: 2366, api: apiClient) { (collection, error) in
            XCTAssert(collection?.id == 2366)
            XCTAssert(collection?.name == "The Jaws Collection")
            XCTAssert(collection?.posterPath == "/fgraZdDCvAtBr0MHczmL6raonHd.jpg")
            XCTAssert(collection?.backdropPath == "/1e2QvI2u7Q4d2admK6Xw0AjLjVp.jpg")
            XCTAssert(collection?.movies?.count == 4)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
