//
//  TodayViewController.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var menuItemsTableView: UITableView!
    
    // MARK: Properties
    
    let visualEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
    let warningLabel     = UILabel()
    
    var menu : Menu!
    var filteredMenuItems : [MenuItem]!
    
    let menuItemTableViewCellIdentifier = "menuItemTableViewCell"

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.warningLabel.textAlignment = .Center
        
        // Add the warning label to the effect view and the effect view to the view
        self.visualEffectView.contentView.addSubview(self.warningLabel)
        self.view.addSubview(visualEffectView)
        
        self.updateView()
        
        self.widgetPerformUpdateWithCompletionHandler()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the visual effect view and warning label's size to be the size of the view
        self.visualEffectView.frame = self.view.bounds
        self.warningLabel.frame = self.visualEffectView.bounds
        
        // Move the warning label to the left to account for the left margin of the today extension
        self.warningLabel.center.x -= (UIScreen.mainScreen().bounds.width - self.view.bounds.width) / 2
    }

    // MARK: Custom Methods
    
    func updateView() {
        if let menu = menu {
            if menu.open {
                self.warningLabel.hidden = true
                
                self.menuItemsTableView.hidden = false
                self.menuItemsTableView.reloadData()
                
                self.preferredContentSize = self.menuItemsTableView.contentSize
            } else {
                self.warningLabel.hidden = false
                self.warningLabel.text   = NSLocalizedString("We're Currently Closed", comment: "")
                
                self.menuItemsTableView.hidden = true
                
                self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 50)
            }
        } else {
            self.warningLabel.hidden = false
            self.warningLabel.text   = NSLocalizedString("No Data Available", comment: "")

            self.menuItemsTableView.hidden = true
            
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 50)
        }
        
        self.view.setNeedsLayout()
    }

    // MARK: NCWidgetProviding
    
    func widgetPerformUpdateWithCompletionHandler(_ completionHandler: ((NCUpdateResult) -> Void) = {result in return}) {
        let calendar = NSCalendar.currentCalendar()
        
        // Call the completion with no data as update result when we already have a menu for the given date
        if self.menu != nil && calendar.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: self.menu.date) ==  calendar.ordinalityOfUnit(.DayCalendarUnit, inUnit: .EraCalendarUnit, forDate: NSDate()){
            completionHandler(.NoData)
            return
        }

        if menu == nil {
            self.warningLabel.text = NSLocalizedString("Loading Data...", comment: "")
            self.warningLabel.hidden = false
        }
        
        RestoManager.sharedManager.retrieveMenuForDate(NSDate(), completionHandler: { (menu, error) -> () in
            if let menu = menu {
                self.menu = menu
                
                // Filter all the menu items to only display the main menu items
                self.filteredMenuItems = menu.menuItems.filter { return $0.type == MenuItemType.Main }
                
                completionHandler(.NewData)
            } else {
                completionHandler(.Failed)
            }
            
            self.updateView()
        })
    }

    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.menu != nil) ? 1 : 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.menu != nil) ? self.filteredMenuItems.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(menuItemTableViewCellIdentifier, forIndexPath: indexPath) as! MenuItemTableViewCell
        cell.menuItem = self.filteredMenuItems[indexPath.row]
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // Set the layout margins explicitly on iOS 8 to force no separator insets
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36
    }
}
