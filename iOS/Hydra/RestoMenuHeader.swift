//
//  RestoMenuHeader.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuHeaderView: UIView {
    @IBOutlet weak var controller: RestoMenuViewController?
    @IBOutlet weak var infoView: UIView?
    @IBOutlet weak var day1View: UIView?
    @IBOutlet weak var day2View: UIView?
    @IBOutlet weak var day3View: UIView?
    @IBOutlet weak var day4View: UIView?
    @IBOutlet weak var day5View: UIView?
    @IBOutlet weak var mapView: UIView?
    
    @IBAction func infoViewPressed(gestureRecognizer: UITapGestureRecognizer) {
        controller?.scrollToIndex(0)
    }
    
    @IBAction func viewPressed(gestureRecognizer: UITapGestureRecognizer) {
        controller?.scrollToIndex((gestureRecognizer.view?.tag)!)
    }
    
    func updateDays() {
        for (index, day) in (controller?.days.enumerate())! {
            updateView(day, onIndex: index)
        }
    }
    
    func updateView(date: NSDate, onIndex index: Int) {
        // Index only days so + 1
        let view = headerViews()[index+1]
        let dayLabel = view?.viewWithTag(998) as! UILabel
        let numberLabel = view?.viewWithTag(999) as! UILabel
        
        let formatter = NSDateFormatter.H_dateFormatterWithAppLocale()
        formatter.dateFormat = "EE"
        dayLabel.text = formatter.stringFromDate(date).uppercaseString
        formatter.dateFormat = "d"
        numberLabel.text = formatter.stringFromDate(date)
    }
    
    func selectedIndex(index: Int) {
        // modify background of label
        for view in headerViews() {
            let numberLabel = view?.viewWithTag(999) as! UILabel
            numberLabel.backgroundColor = UIColor.clearColor()
            numberLabel.layer.borderColor = UIColor.clearColor().CGColor
        }
        let view = headerViews()[index]
        let numberLabel = view?.viewWithTag(999) as! UILabel
        numberLabel.layer.masksToBounds = true
        numberLabel.layer.borderColor = UIColor.whiteColor().CGColor
        numberLabel.layer.borderWidth = 2
        numberLabel.layer.cornerRadius = 15
    }
    
    func headerViews() -> [UIView?] {
        return [infoView, day1View, day2View, day3View, day4View, day5View]
    }
}