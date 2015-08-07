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
                    dayLabel.text = "" + formatter.stringFromDate(restoMenu!.day)
                }
            } else {
                dayLabel.text = ""
                closedLabel.hidden = false
            }
            tableView.reloadData()
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
        var cell = tableView.dequeueReusableCellWithIdentifier("restoMenuTableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "restoMenuTableViewCell")
        }
        let meat = restoMenu?.meat[indexPath.row] as? RestoMenuItem
        cell!.textLabel?.text = meat?.name
        cell!.detailTextLabel?.text = meat?.price
        
        return cell!
    }
}
