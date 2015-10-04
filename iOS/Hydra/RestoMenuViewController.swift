//
//  RestoMenuViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 14/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class RestoMenuViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var restoMenuHeader: RestoMenuHeaderView?
    
    var days: [NSDate] = []
    var menus: [RestoMenu?] = []
    var legend: [RestoLegendItem] = []
    
    var currentIndex: Int = 1
    
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
        self.restoMenuHeader?.updateDays()
        //self.collectionView?.reloadData() // Uncomment when bug is fixed
        //self.scrollToIndex(self.currentIndex, animated: false)
        
        // REMOVE ME IF THE BUG IS FIXED, THIS IS UGLY
        if #available(iOS 9, *) {
            NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("refreshDataTimer:"), userInfo: nil, repeats: false)
        }
    }
    
    func refreshDataTimer(timer: NSTimer){ // REMOVE ME WHEN THE BUG IS FIXED
        self.collectionView?.reloadData()
        self.scrollToIndex(self.currentIndex, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.days = calculateDays()
        self.restoMenuHeader?.updateDays()
        //do not hide if in moreController
        if self.parentViewController != self.tabBarController?.moreNavigationController {
            if UIApplication.sharedApplication().statusBarStyle != .LightContent {
                UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
            }
            self.navigationController?.navigationBarHidden = true
        }
        // scroll to today
        self.scrollToIndex(currentIndex, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: false)
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
        debugPrint("Reloading menu")
        self.loadMenu()
        self.collectionView?.reloadData()
    }
    
    func reloadInfo() {
        // New info is available
        debugPrint("Reloading info")
        self.legend = (RestoStore.sharedStore().legend as? [RestoLegendItem])!
        self.collectionView?.reloadData()
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)

            return cell
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
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let pageWidth = Float(self.collectionView!.frame.size.width)
        let currentOffset = Float(scrollView.contentOffset.x)
        let targetOffset = Float(targetContentOffset.memory.x) + pageWidth/2

        let index = max(min(Int(round(targetOffset / pageWidth))-1, (self.collectionView?.numberOfItemsInSection(0))!-1),0)
        
        targetContentOffset.memory = CGPointMake(CGFloat(currentOffset), 0)

        self.scrollToIndex(index, animated: true)
    }
}

// MARK: - Header view actions
extension RestoMenuViewController {
    func scrollToIndex(index: Int, animated: Bool = true) {
        self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
        self.restoMenuHeader?.selectedIndex(index)
        currentIndex = index
    }
    
    func scrollToDate(date: NSDate) {
        for (index, day) in days.enumerate() {
            if day.dateAtStartOfDay().isEqualToDate(date.dateAtStartOfDay()) {
                self.scrollToIndex(index+1)
                return
            }
        }
    }
}