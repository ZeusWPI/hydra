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
}

extension RestoMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            return collectionView.dequeueReusableCellWithReuseIdentifier("infoCell", forIndexPath: indexPath)
        default:
            return collectionView.dequeueReusableCellWithReuseIdentifier("restoMenuOpenCell", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height) // cells always fill the whole screen
    }
}