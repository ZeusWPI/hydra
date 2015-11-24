//
//  ActivityOverviewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 24/11/2015.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

@objc class ActivityOverviewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var activity: AssociationActivity? {
        didSet {
            associationLabel.text = activity?.association.displayName
            titleLabel.text = activity?.title

            let dateStartFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            dateStartFormatter.dateFormat = "H:mm";
            dateLabel.text = "\(dateStartFormatter.stringFromDate((self.activity?.start)!))"
        }
    }

}