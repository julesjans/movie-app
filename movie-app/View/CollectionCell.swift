//
//  CollectionCell.swift
//  bbc-app
//
//  Created by Julian Jans on 09/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

@IBDesignable
class CollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView?

    override func prepareForReuse() {
        title.text = ""
        imageView?.image = nil
    }

}
