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
    @IBOutlet weak var imageView: UIImageView!

    var activity: AssociationActivity? {
        didSet {
            let longDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            longDateFormatter.timeStyle = .ShortStyle
            longDateFormatter.dateStyle = .LongStyle
            longDateFormatter.doesRelativeDateFormatting = true
            
            let shortDateFormatter = NSDateFormatter.H_dateFormatterWithAppLocale()
            shortDateFormatter.timeStyle = .ShortStyle
            shortDateFormatter.dateStyle = .NoStyle
            
            associationLabel.text = activity?.association.displayName
            titleLabel.text = activity?.title
            
            if (self.activity!.end != nil) {
                if self.activity!.start.dateByAddingDays(1).isLaterThanDate(self.activity!.end) {
                    dateLabel.text = "\(longDateFormatter.stringFromDate((self.activity?.start)!)) - \(shortDateFormatter.stringFromDate((self.activity?.end)!))"
                } else {
                    dateLabel.text = "\(longDateFormatter.stringFromDate((self.activity?.start)!)) - \(longDateFormatter.stringFromDate((self.activity?.end)!))"
                }
            } else {
                dateLabel.text = longDateFormatter.stringFromDate((self.activity?.start)!)
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
            
            if let url = activity?.facebookEvent?.smallImageUrl {
                imageView.sd_setImageWithURL(url, placeholderImage: imageView.image)
            } else {
                imageView.image = nil
            }
        }
    }
}