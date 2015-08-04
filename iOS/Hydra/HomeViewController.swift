//
//  HomeViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 30/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    let homeFeedService = HomeFeedService.sharedService

    var feedItems = HomeFeedService.sharedService.createFeed()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: "startRefresh", forControlEvents: .ValueChanged)
        self.feedCollectionView.addSubview(refreshControl)
        self.feedCollectionView.alwaysBounceVertical = true
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    func startRefresh() {
        //self.homeFeedService.refreshStores()
        self.feedItems = self.homeFeedService.createFeed()
        
        self.feedCollectionView.reloadData()
        
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("restoCell", forIndexPath: indexPath) as? HomeRestoCollectionViewCell
            cell?.restoMenu = feedItem.object as? RestoMenu
            return cell!
        case .SchamperNewsItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("schamperCell", forIndexPath: indexPath) as? HomeSchamperCollectionViewCell
            cell!.article = feedItem.object as? SchamperArticle
            return cell!
        case .ActivityItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityCell", forIndexPath: indexPath) as? HomeActivityCollectionViewCell
            cell?.activity = feedItem.object as? AssociationActivity
            return cell!
        case .NewsItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("newsItemCell", forIndexPath: indexPath) as? HomeNewsItemCollectionViewCell
            cell?.article = feedItem.object as? AssociationNewsItem
            return cell!
        case .UrgentItem:
            return collectionView.dequeueReusableCellWithReuseIdentifier("urgentfmCell", forIndexPath: indexPath)
        case .SettingsItem:
            return collectionView.dequeueReusableCellWithReuseIdentifier("settingsCell", forIndexPath: indexPath)
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier("testCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "homeHeader", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            let restoMenu = feedItem.object as? RestoMenu
            var count = 1
            if (restoMenu != nil && restoMenu!.open) {
                count = restoMenu!.meat.count
            }

            return CGSizeMake(self.view.frame.size.width, CGFloat(106+count*17))
        case .ActivityItem:
            let activity = feedItem.object as? AssociationActivity
            //TODO: guess height of cell
            return CGSizeMake(self.view.frame.size.width, 180)
        case .SettingsItem:
            return CGSizeMake(self.view.frame.size.width, 80)
        case .NewsItem:
            return CGSizeMake(self.view.frame.size.width, 100)
        default:
            return CGSizeMake(self.view.frame.size.width, 135) //TODO: per type
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            self.navigationController?.pushViewController(RestoMenuController(), animated: true)
        case .ActivityItem:
            self.navigationController?.pushViewController(ActivityDetailController(activity: feedItem.object as! AssociationActivity, delegate: nil), animated: true)
        case .SchamperNewsItem:
            let article = feedItem.object as! SchamperArticle
            if !article.read {
                article.read = true
            }
            
            self.navigationController?.pushViewController(SchamperDetailViewController(article: article), animated: true)
        case .NewsItem:
            self.navigationController?.pushViewController(NewsDetailViewController(newsItem: feedItem.object as! AssociationNewsItem), animated: true)
        case .SettingsItem:
            self.navigationController?.pushViewController(PreferencesController(), animated: true)
        default: break
        }
    }
}