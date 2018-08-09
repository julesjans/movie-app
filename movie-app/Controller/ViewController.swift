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
    var fetchPage = 1
    var totalPages = 1
    
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Now Playing", comment: "Now playing header")
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetData), name: .UIApplicationWillEnterForeground, object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: UIControlEvents.valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if items.count == 0 {
            activityIndicator.startAnimating()
        }
        getData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    
        let point = CGPoint(x: 0, y: collectionView.contentOffset.y + view.safeAreaInsets.top)
        // When scrolling to a cell on rotate: use the cell at the top left or use the cell in the center?
        // let point = view.convert(collectionView.center, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        if let indexPath = indexPath {
            coordinator.animate(alongsideTransition: { (_) in
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            })
        }
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
        guard fetchPage <= totalPages else { return }
        
        isLoading = true
        NowPlaying.get(id: fetchPage, api: apiClient) { (nowPlaying, error) in
            self.isLoading = false
            self.fetchPage += 1
            guard error == nil, nowPlaying != nil else {
                assertionFailure()
                return
            }
            if let totalPages = nowPlaying?.totalPages {
                self.totalPages = totalPages
            }
            if let movies = nowPlaying?.movies {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let startIndex = self.items.count
                    self.items.append(contentsOf: movies)
                    let indexes = (startIndex..<self.items.count).map { IndexPath(row: $0, section: 0)}
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: indexes)
                    })
                }
            }
        }
    }
    
    @objc func resetData() {
        fetchPage = 1
        items = [Movie]()
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        collectionView.reloadData()
        if navigationController?.topViewController != self {
            navigationController?.popToViewController(self, animated: false)
        }
    }
    
    @objc func refreshData() {
        fetchPage = 1
        items = [Movie]()
        collectionView.performBatchUpdates({
            self.collectionView.reloadSections(IndexSet(integersIn: 0...0))
        }, completion: { (_) in
            self.collectionView.refreshControl?.endRefreshing()
            self.getData()
        })
    }
    
}

// MARK: UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    
    // Get more data when the page is scrolled down
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        if !isLoading && (maximumOffset - contentOffset <= (view.bounds.size.height / 2)) {
            getData()
        }
    }
    
}

// MARK: UICollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
        let item = items[indexPath.row]
        cell.title.text = item.title
        
        if let rating = item.voteAverage {
            cell.ratingView?.value = CGFloat(rating)
        }
        
        if let posterPath = item.posterPath {
            apiClient.image(for: posterPath) { (pathString, image, error) in
                guard error == nil, image != nil else {
                    assertionFailure()
                    return
                }
                DispatchQueue.main.async {
                    if posterPath == pathString {
                        cell.imageView?.image = image
                    }
                }
            }
        } else {
            cell.imageView?.image = UIImage(named: "image.jpg")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Helper method for calculating a CGSize from a given grid.
        func sizeForGrid(_ horizontal: CGFloat, _ vertical: CGFloat) -> CGSize {
            let width = (collectionView.bounds.size.width / horizontal)
            let height = (collectionView.bounds.size.height - view.safeAreaInsets.top) / vertical
            return CGSize(width: width, height: height)
        }
        
        // Calculate a preferred cell size based on size classes and the size of the display.
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        // iPad
        case (.regular, .regular):
            return sizeForGrid(4.0, 3.0)
        // iPhone Portrait
        case (.compact, .regular):
            return sizeForGrid(2.0, 3.0)
        // iPhone Plus Landscape
        case (.regular, .compact):
            return sizeForGrid(4.0, 2.0)
        // iPhone Landscape
        case (.compact, .compact):
            return sizeForGrid(3.0, 2.0)
        default:
            return sizeForGrid(2.0, 2.0)
        }
    }
    
}

