//
//  HomeSchamperCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeSchamperCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var article: SchamperArticle? {
        didSet {
            titleLabel.text = article?.title
            let dateTransformer = SORelativeDateTransformer()
            dateLabel.text = dateTransformer.transformedValue(article?.date) as! String?
            authorLabel.text = article?.author
        }
    }

}