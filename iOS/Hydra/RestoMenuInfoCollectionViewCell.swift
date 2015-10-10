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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let legend = self.legend {
            return legend.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoItemCell") as? RestoLegendItemTableViewCell
        
        cell?.item = legend?[indexPath.item]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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