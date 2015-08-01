//
//  HomeUrgentCollectionViewCell.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 02/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HomeUrgentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    override func awakeFromNib() {
        notificationCenter.addObserver(self, selector: "playerStatusChanged:", name: UrgentPlayerDidChangeStateNotification, object: nil)
        button.selected = UrgentPlayer.sharedPlayer().isPlaying()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @IBAction func playButtonTapped(sender: UIButton) {
        let player = UrgentPlayer.sharedPlayer()
        if player.isPlaying() {
            player.pause()
        } else {
            player.play()
        }
    }
    
    func playerStatusChanged(notification: NSNotification) {
        button.selected =  UrgentPlayer.sharedPlayer().isPlaying()
    }
}