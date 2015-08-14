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
    @IBOutlet weak var mapView: UIView?
    
    @IBAction func infoViewPressed(gestureRecognizer: UITapGestureRecognizer) {
        controller?.scrollToIndex(0)
    }
    
    @IBAction func firstViewPressed(gestureRecognizer: UITapGestureRecognizer) {
        controller?.scrollToIndex(1)
    }
}