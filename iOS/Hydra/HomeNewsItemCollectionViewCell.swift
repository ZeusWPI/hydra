//
//  HomeNewsItemCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 05/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeNewsItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var assocationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var highlightImage: UIImageView!
    
    var article: AssociationNewsItem? {
        didSet {
            titleLabel.text = article?.title
            let dateTransformer = SORelativeDateTransformer()
            dateLabel.text = dateTransformer.transformedValue(article?.date) as! String?
            assocationLabel.text = article?.association.displayName
            highlightImage.hidden = !article!.highlighted
        }
    }
}