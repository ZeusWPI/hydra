//
//  HomeViewController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 30/07/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            return collectionView.dequeueReusableCellWithReuseIdentifier("restoCell", forIndexPath: indexPath)
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier("testCell", forIndexPath: indexPath)
        }

    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "homeHeader", forIndexPath: indexPath)
    }
}