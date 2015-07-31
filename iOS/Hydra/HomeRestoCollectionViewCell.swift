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
    
    var restoMenu: RestoMenu?
    
    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = restoMenu?.meat.count {
            debugPrint(String(format:"The count: %2d", count))
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("restoMenuTableViewCell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "restoMenuTableViewCell")
        }
        let meat = restoMenu?.meat[indexPath.row] as? RestoMenuItem
        debugPrint("Creating an new cell: " + (meat?.name)!)
        cell!.textLabel?.text = meat?.name
        cell!.detailTextLabel?.text = meat?.price
        
        return cell!
    }
}
