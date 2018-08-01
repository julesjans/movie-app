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
    
    // Switch to testing the live API, although attributes will likely change!
    // var apiClient = APIClientLive()
    var apiClient = APIClientMock()
    
    func testNowPlayingFromAPI() {
        let promise = expectation(description: "testNowPlayingFromAPI")
        NowPlaying.get(id: 1, api: apiClient) { (nowPlaying, error) in
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
        Movie.get(id: 353081, api: apiClient) { (movie, error) in
            XCTAssert(movie?.id == 353081)
            XCTAssert(movie?.title == "Mission: Impossible - Fallout")
            XCTAssert(movie?.posterPath == "/AkJQpZp9WoNdj7pLYSj1L0RcMMN.jpg")
            XCTAssert(movie?.backdropPath == "/5qxePyMYDisLe8rJiBYX8HKEyv2.jpg")
            XCTAssert(movie?.voteAverage == 7.5)
            XCTAssert(movie?.voteCount == 263)
            XCTAssert(movie?.genres!.count == 3)
            XCTAssert(movie?.collection?.name == "Mission: Impossible Collection")
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
        MovieCollection.get(id: 87359, api: apiClient) { (collection, error) in
            XCTAssert(collection?.id == 87359)
            XCTAssert(collection?.name == "Mission: Impossible Collection")
            XCTAssert(collection?.posterPath == "/gwyJPIhCK4Xz2WogeBnhCSQfUek.jpg")
            XCTAssert(collection?.backdropPath == "/1kvKAHlSdFZTT9mhAXR54ggkxOU.jpg")
            XCTAssert(collection?.movies?.count == 6)
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
