//
//  ViewController.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Initializer for the APIClient, uses the mock API for testing environments.
    // In a larger project this would be shared across the app, and not coupled to a view controller like this.
    lazy var apiClient: APIClient = {
        if ProcessInfo.processInfo.arguments.contains("APIClientMock") {
            return APIClientMock()
        } else {
            return APIClientLive()
        }
    }()
    
    var items = [Movie]()
    var isLoading = false
    var lastFetchedPage = 0
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Now Playing", comment: "Now playing header")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
                let item = items[indexPath.row]
                if let detail = segue.destination as? DetailViewController {
                    detail.apiClient = apiClient
                    detail.selectedItem = item
                }
            }
        }
    }
    
}

// MARK: Fetching data
extension ViewController {
    
    func getData() {
        
        isLoading = true
        lastFetchedPage += 1
        
        NowPlaying.get(id: lastFetchedPage, api: apiClient) { (nowPlaying, error) in
            if let movies = nowPlaying?.movies {
                DispatchQueue.main.async {
                    let startIndex = self.items.count
                    self.items.append(contentsOf: movies)
                    let indexes = (startIndex..<self.items.count).map { IndexPath(row: $0, section: 0)}
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: indexes)
                    })
                }
            }
            self.isLoading = false
        }
    }
    
}

// MARK: UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    
    // Get more data when the page is scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if !isLoading && (maximumOffset - contentOffset <= 100) {
            getData()
        }
    }
    
}

// MARK: UICollectionViewDelegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
        let item = items[indexPath.row]
        
        cell.title.text = item.title
        if let posterPath = item.posterPath {
            apiClient.image(for: posterPath) { (url, image, error) in
                if posterPath == url {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Helper method for calculating a CGSize from a given grid.
        func sizeForGrid(_ horizontal: CGFloat, _ vertical: CGFloat) -> CGSize {
            let width = (collectionView.bounds.size.width / horizontal)
            let height = (collectionView.bounds.size.height / vertical)
            return CGSize(width: width, height: height)
        }
        
        // Calculate a preferred cell size based on size classes and the size of the display.
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        // iPad
        case (.regular, .regular):
            if collectionView.bounds.size.width > collectionView.bounds.size.height {
                // iPad Landscape
                return sizeForGrid(4.0, 3.0)
            } else {
                // iPad Portrait
                return sizeForGrid(4.0, 4.0)
            }
        // iPhone Portrait
        case (.compact, .regular):
            return sizeForGrid(2.0, 3.0)
        // iPhone Plus Landscape
        case (.regular, .compact):
            return sizeForGrid(4.0, 2.0)
        // iPhone Landscape
        case (.compact, .compact):
            return sizeForGrid(3.0, 2.0)
        // This should not be necessary
        default:
            return sizeForGrid(2.0, 2.0)
        }
    }
    
}

