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
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionLabel: UILabel!
    @IBOutlet var collectionViewContraints: [NSLayoutConstraint]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(apiClient != nil)
        assert(selectedItem != nil)
        Movie.get(id: selectedItem?.id, api: apiClient!) { (movie, error) in
            assert(movie != nil)
            DispatchQueue.main.async {
                self.selectedItem = movie
                self.configureView()
                if let collection = self.selectedItem?.collection {
                    MovieCollection.get(id: collection.id, api: self.apiClient!, completion: { (collection, error) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView.indexPathsForSelectedItems?.first {
                let item = selectedCollection?.movies?[indexPath.row]
                if let detail = segue.destination as? DetailViewController {
                    detail.apiClient = apiClient
                    detail.selectedItem = item
                }
            }
        }
    }
    
}

// MARK: Configuring the view
extension DetailViewController {
    
    func configureView() {
        titleLabel.text = selectedItem?.title
        overviewLabel.text = selectedItem?.overview
        
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
                }
            }
        }
    }
    
}

// MARK: UICollectionViewDelegates
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCollection?.movies?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionCell
        let item = selectedCollection?.movies?[indexPath.row]
        cell.title.text = item?.title
        if let posterPath = item?.posterPath {
            apiClient!.image(for: posterPath) { (url, image, error) in
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
        return CGSize(width: ((collectionView.bounds.size.height / 3 ) * 2) , height: collectionView.bounds.size.height)
    }
    
}
