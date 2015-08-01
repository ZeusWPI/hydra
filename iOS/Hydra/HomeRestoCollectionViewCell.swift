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
    
    var restoMenu: RestoMenu? {
        didSet {
            if restoMenu != nil {
                if restoMenu!.day.isToday() {
                    dayLabel.text = "Menu vandaag"
                } else if restoMenu!.day.isTomorrow() {
                    dayLabel.text = "Menu morgen"
                } else {
                    let formatter = NSDateFormatter.H_dateFormatterWithAppLocale()
                    formatter.dateFormat = "EEEE d MMMM"
                    dayLabel.text = "Menu " + formatter.stringFromDate(restoMenu!.day)
                }
            } else {
                dayLabel.text = "Menu"
            }
            //TODO: test if closed, and add banner or something
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
