//
//  RestoMenuViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var restoMenuHeader: RestoMenuHeaderView!
    
    
    var days: [NSDate] = []
    var menus: [RestoMenu?] = []
    var legend: [RestoLegendItem] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "reloadMenu", name: RestoStoreDidReceiveMenuNotification, object: nil)
        center.addObserver(self, selector: "reloadInfo", name: RestoStoreDidUpdateInfoNotification, object: nil)
        center.addObserver(self, selector: "applicationDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        days = calculateDays()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMenu()
        self.legend = (RestoStore.sharedStore().legend as? [RestoLegendItem])!
        // update days and reloadData
        self.restoMenuHeader.updateDays()
        self.collectionView.reloadData()
        
        // scroll to today
        self.scrollToIndex(1)
        self.restoMenuHeader.selectedIndex(1)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //do not hide if in moreController
        if self.parentViewController != self.tabBarController?.moreNavigationController {
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    func loadMenu() {
        // New menus are available
        let store = RestoStore.sharedStore()
        var menus = [RestoMenu?]()
        for day in days {
            let menu = store.menuForDay(day) as RestoMenu?
            menus.append(menu)
        }
        self.menus = menus
    }
    
    func reloadMenu() {
        self.loadMenu()
        self.collectionView.reloadData()
    }
    
    func reloadInfo() {
        // New info is available
        self.legend = (RestoStore.sharedStore().legend as? [RestoLegendItem])!
        self.collectionView.reloadData()
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        let firstDay = self.days[0]
        self.days = self.calculateDays()
        
        if !firstDay.isEqualToDateIgnoringTime(self.days[0]) {
            self.reloadMenu()
        }
    }
    
    func calculateDays() -> [NSDate] {
        // Find the next x days to display
        var day = NSDate()
        var days = [NSDate]()
        while (days.count < 5) {
            if day.isTypicallyWorkday() {
                days.append(day)
            }
            day = day.dateByAddingDays(1)
        }
        return days
    }
    
    // MARK: - Headerview actions
    
    @IBAction func mapViewPressed(gestureRecognizer: UITapGestureRecognizer) {
        debugPrint("Map view pressed!")
        if let navigationController = self.navigationController {
            navigationController.pushViewController(RestoMapController(), animated: true)
        } else {
            fatalError("An navigationcontroller should be present")
        }
    }
}

// MARK: - Collection view data source & delegate
extension RestoMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.days.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0: // info cell
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        case 1...self.days.count:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("restoMenuOpenCell", forIndexPath: indexPath) as! RestoMenuCollectionCell
            
            cell.restoMenu = self.menus[indexPath.row-1]
            return cell
        default:
            debugPrint("Shouldn't be here")
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height) // cells always fill the whole screen
    }
}

extension RestoMenuViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let center = self.collectionView.contentOffset.x + self.view.frame.width/2
        for cell in self.collectionView.visibleCells() {
            let indexPath = self.collectionView.indexPathForCell(cell)
            // Cell takes more than 50% of the screen
            if cell.frame.origin.x < center && cell.frame.origin.x + cell.frame.width > center {
                self.scrollToIndex(indexPath!.row)
                self.restoMenuHeader.selectedIndex(indexPath!.row)
            }
        }
    }
}

// MARK: - Header view actions
extension RestoMenuViewController {
    func scrollToIndex(index: Int) {
        self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    }
}