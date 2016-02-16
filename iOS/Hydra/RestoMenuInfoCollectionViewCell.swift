//
//  RestoMenuInfoCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 26/09/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuInfoCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var legend: [RestoLegendItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var sandwiches: [RestoSandwich]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            if let legend = self.legend {
                return legend.count
            }
        case 1:
            if let sandwiches = self.sandwiches {
                return sandwiches.count
            }
        default: break
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("infoItemCell") as? RestoLegendItemTableViewCell
            
            cell?.item = legend?[indexPath.item]
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("sandwichCell") as? RestoSandwichTableViewCell
            
            cell?.item = sandwiches?[indexPath.item]
            
            return cell!
        default:
            return tableView.dequeueReusableCellWithIdentifier("infoItemCell")!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let item = legend?[indexPath.item]
            
            let size = CGSizeMake(tableView.frame.width - 40, CGFloat.max)
            let paragraphStyle = NSParagraphStyle()
            //paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            //paragraphStyle.alignment = NSTextAlignment.Left
            
            let attributes = [
                NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            
            let mutableText = NSMutableAttributedString(string: (item?.value)!, attributes: attributes)
            
            let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
                NSStringDrawingOptions.UsesFontLeading.rawValue,
                NSStringDrawingOptions.self)
            
            let labelSize: CGSize = mutableText.boundingRectWithSize(size, options: options, context: nil).size
            
            return labelSize.height + 5
        }
        
        return 25
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let frame = CGRectMake(0, 0, self.bounds.width, 40)
            let header = UIView(frame: frame)
            
            let label = UILabel(frame: frame)
            label.textAlignment = .Center
            label.text = "Broodjes"
            label.baselineAdjustment = .AlignCenters
            label.textColor = UIColor.whiteColor()
            
            header.addSubview(label)
            
            return header
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        }
        return 0
    }
}

class RestoLegendItemTableViewCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var item: RestoLegendItem? {
        didSet {
            if let item = item {
                keyLabel.text = item.key
                valueLabel.text = item.value
            }
        }
    }
}

class RestoSandwichTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var smallPriceLabel: UILabel!
    @IBOutlet weak var mediumPriceLabel: UILabel!
    
    var item: RestoSandwich? {
        didSet {
            if let item = item {
                self.nameLabel.text = item.name
                self.smallPriceLabel.text = "€ " + item.priceSmall
                self.mediumPriceLabel.text = "€ " + item.priceMedium
            }
        }
    }
}