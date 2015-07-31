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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let feedItem = feedItems[indexPath.row]
        
        switch feedItem.itemType {
        case .RestoItem:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("restoCell", forIndexPath: indexPath)
            if let day_label = cell.viewWithTag(112) as? UILabel {
                day_label.text = "Menu morgen"
            }
            return cell
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier("testCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "homeHeader", forIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.frame.size.width, 175) //TODO: per type
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    //MARK: - Buttons
    @IBAction func showResto(sender: UIButton) {
        print("Switching to Resto")
        self.navigationController?.pushViewController(RestoMenuController(), animated: true)
    }
}