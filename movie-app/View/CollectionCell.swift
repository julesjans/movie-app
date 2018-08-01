//
//  CollectionCell.swift
//  movie-app
//
//  Created by Julian Jans on 31/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

@IBDesignable
class CollectionCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var ratingView: Rating?

    override func prepareForReuse() {
        title.text = ""
        imageView?.image = nil
        ratingView?.value = 0.0
    }

}
