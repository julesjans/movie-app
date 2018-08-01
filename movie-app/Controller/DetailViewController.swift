//
//  DetailViewController.swift
//  movie-app
//
//  Created by Julian Jans on 30/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var apiClient: APIClient?
    var selectedItem: Movie?
    var selectedCollection: MovieCollection?
    
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var ratingView: Rating!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionLabel: UILabel!
    @IBOutlet var collectionViewContraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem()
        button.title = "Back"
        navigationItem.backBarButtonItem = button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.alpha = 0.0
        activityIndicator.startAnimating()
        getData()
    }
    
}

// MARK: Fetching data and configuring the view
extension DetailViewController {
    
    func getData() {
        guard let apiClient = apiClient, let id = selectedItem?.id else {
            assertionFailure()
            return
        }
        
        Movie.get(id: id, api: apiClient) { (movie, error) in
            assert(movie != nil)
            DispatchQueue.main.async {
                self.selectedItem = movie
                self.configureView()
                if let collection = self.selectedItem?.collection {
                    MovieCollection.get(id: collection.id, api: apiClient, completion: { (collection, error) in
                        assert(collection != nil)
                        DispatchQueue.main.async {
                            self.selectedCollection = collection
                            self.collectionView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    func configureView() {
        titleLabel.text = selectedItem?.title
        overviewLabel.text = selectedItem?.overview
        if let rating = selectedItem?.voteAverage {
            ratingView.value = CGFloat(rating)
        }
        if let collectionName = selectedItem?.collection?.name {
            collectionLabel.text = collectionName
            NSLayoutConstraint.activate(collectionViewContraints)
        } else {
            collectionLabel.text = nil
            NSLayoutConstraint.deactivate(collectionViewContraints)
        }
        if let posterPath = selectedItem?.posterPath {
            apiClient?.image(for: posterPath) { (url, image, error) in
                DispatchQueue.main.async {
                    self.imageView?.image = image
                    UIView.animate(withDuration: 0.2, animations: {
                        self.activityIndicator.stopAnimating()
                        self.scrollView.alpha = 1.0
                    })
                }
            }
        } else {
            imageView?.image = UIImage(named: "image.jpg")
            UIView.animate(withDuration: 0.2, animations: {
                self.activityIndicator.stopAnimating()
                self.scrollView.alpha = 1.0
            })
        }
    }
    
}

// MARK: UICollectionView
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCollection?.movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = selectedCollection?.movies?[indexPath.row] {
            push(item: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
        let item = selectedCollection?.movies?[indexPath.row]
        cell.title.text = item?.title
        if let rating = item?.voteAverage {
            cell.ratingView?.value = CGFloat(rating)
        }
        if let posterPath = item?.posterPath {
            apiClient!.image(for: posterPath) { (url, image, error) in
                if posterPath == url {
                    DispatchQueue.main.async {
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
        return CGSize(width: ((collectionView.bounds.size.height / 3 ) * 2) , height: collectionView.bounds.size.height)
    }
    
}

// MARK: Navigation
extension DetailViewController {
    
    /// Navigating to a movie detail: if there is already a detail showing that item pop back to it, else push a new controller on.
    func push(item: Movie) {
        if let existingController = navigationController?.viewControllers.filter({ (controller) -> Bool in
            if let detailView = controller as? DetailViewController {
                return detailView.selectedItem?.id == item.id
            } else {
                return false
            }
        }).first as? DetailViewController {
            navigationController?.popToViewController(existingController, animated: true)
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let controller = storyBoard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                controller.apiClient = apiClient
                controller.selectedItem = item
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
