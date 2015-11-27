//
//  HomeRestoCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 31/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeRestoCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    
    var restoMenu: RestoMenu? {
        didSet {
            if restoMenu != nil {
                closedLabel.hidden = restoMenu!.open
                if restoMenu!.day.isToday() {
                    dayLabel.text = "vandaag"
                } else if restoMenu!.day.isTomorrow() {
                    dayLabel.text = "morgen"
                } else {
                    let formatter = NSDateFormatter.H_dateFormatterWithAppLocale()
                    formatter.dateFormat = "EEEE d MMMM"
                    dayLabel.text = formatter.stringFromDate(restoMenu!.day)
                }
            } else {
                dayLabel.text = ""
                closedLabel.hidden = false
            }
            tableView.reloadData()
            self.layoutSubviews() // call this to force an update after setting the new menu, so the tableview height changes.
        }
    }
    
    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restoMenu!.open {
            if let count = restoMenu?.meat.count where restoMenu!.open{
                return count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("restoMenuTableViewCell") as? HomeRestoMenuItemTableViewCell

        cell!.menuItem = restoMenu?.meat[indexPath.row] as? RestoMenuItem

        return cell!
    }
}

class HomeRestoMenuItemTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var menuItem: RestoMenuItem? {
        didSet {
            if let menuItem = menuItem {
                nameLabel.text = menuItem.name
                priceLabel.text = menuItem.price
                self.contentView.layoutIfNeeded() // relayout when prices are added
            }
        }
    }
}
