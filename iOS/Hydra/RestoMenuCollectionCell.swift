//
//  RestoMenuCollectionCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var restoMenu: RestoMenu? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        tableView.separatorColor = UIColor.clearColor()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4; //TODO: add maaltijdsoep
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = restoMenu where menu.open {
            let restoMenuSection = RestoMenuSection(rawValue: section)
            switch restoMenuSection! {
            case .Soup:
                return restoMenu?.soup != nil ? 1 : 0
            case .Meat:
                return (restoMenu?.meat.count)!
            case .Vegetable:
                return (restoMenu?.vegetables.count)!
            default:
                return 0
            }

        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuItemCell") as? RestoMenuItemTableViewCell

        cell?.backgroundColor = UIColor.clearColor() // for iPads, for some strange the cells lose their color

        let restoMenuSection = RestoMenuSection(rawValue: indexPath.section)
        switch restoMenuSection! {
        case .Soup:
            cell!.menuItem = restoMenu?.soup
        case .Meat:
            cell!.menuItem = restoMenu?.meat[indexPath.row] as? RestoMenuItem
        case .Vegetable:
            cell!.vegetable = restoMenu?.vegetables[indexPath.row] as? String
        default: break
        }
        
        return cell!
    }
    
    // Using footers of the previous section instead of headers so they scroll
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Zero height for last section footer
        return section < 3 ? 40 : 0
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        // Return nil if last footer
        if section == 3 {
            return nil
        }
        let frame = CGRectMake(0, 0, self.bounds.width, 40)
        let header = UIView(frame: frame)
        
        let label = UILabel(frame: frame)
        label.textAlignment = .Center
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        } else {
            // Fallback on earlier versions
            label.font = UIFont.systemFontOfSize(20)
        }
        label.baselineAdjustment = .AlignCenters
        label.textColor = UIColor.whiteColor()
        let restoMenuSection = RestoMenuSection(rawValue: section+1)
        switch restoMenuSection! {
        case .Soup:
            label.text = "SOEP"
        case .Meat:
            label.text = "VLEES & VEGGIE"
        case .Vegetable:
            label.text = "GROENTEN"
        default:
            return header
        }
        
        header.addSubview(label)
        return header
    }
}

class RestoMenuItemTableViewCell: UITableViewCell {
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
    
    var vegetable: String? {
        didSet {
            if let vegetable  = vegetable {
                nameLabel.text = vegetable
                priceLabel.text = ""
            }
        }
    }
}

enum RestoMenuSection: Int {
    case Soup = 1, Meat = 3, Vegetable = 2, Empty = 0
}