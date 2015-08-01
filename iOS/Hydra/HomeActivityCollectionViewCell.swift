//
//  HomeActivityCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeActivityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var activity: AssociationActivity? {
        didSet {
            associationLabel.text = activity?.association.displayName
            
            let dateStartFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            dateStartFormatter.dateFormat = "EEE d MMMM H:mm";
            let dateEndFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            titleLabel.text = activity?.title
            dateEndFormatter.dateFormat = "H:mm";
            if (self.activity!.end != nil) {
                if self.activity!.start.dateByAddingDays(1).isLaterThanDate(self.activity!.end) {
                    dateLabel.text = "\(dateStartFormatter.stringFromDate((self.activity?.start)!)) - \(dateEndFormatter.stringFromDate((self.activity?.end)!))"
                } else {
                    dateLabel.text = "\(dateStartFormatter.stringFromDate((self.activity?.start)!)) - \(dateStartFormatter.stringFromDate((self.activity?.end)!))"
                }
            } else {
                dateLabel.text = "\(dateStartFormatter.stringFromDate((self.activity?.start)!))"
            }
            
            descriptionLabel.text = activity?.descriptionText
            var distance: Double? = nil
            if (activity?.latitude != nil && activity?.longitude != nil) {
                distance = LocationService.sharedService.calculateDistance(activity!.latitude, longitude: activity!.longitude)
            }
            
            if let d = distance where d < 100*1000{
                if d < 1000 {
                    locationLabel.text = activity!.location + " (\(Int(d))m)"
                } else {
                    locationLabel.text = activity!.location + " (\(Int(d/1000))km)"
                }
            } else {
                locationLabel.text = activity?.location
            }
        }
    }
    
}