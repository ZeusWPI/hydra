//
//  HydraTabbarController.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 11/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import UIKit

class HydraTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let newsViewController = UINavigationController(rootViewController: NewsViewController()) // find way without instantiating view controllers
        let activityController = UINavigationController(rootViewController: ActivitiesController())
        let restoController = UINavigationController(rootViewController: RestoMenuController())
        let infoController = UINavigationController(rootViewController: InfoViewController())
        let schamperController = UINavigationController(rootViewController: SchamperViewController())
        let prefsController = UINavigationController(rootViewController: PreferencesController())
        let urgentController = UrgentViewController()
        
        restoController.tabBarItem.title = "Resto Menu"
        restoController.tabBarItem.image = UIImage(named: "tabbar-resto.png")
        
        infoController.tabBarItem.image = UIImage(named: "tabbar-info.png")
        
        activityController.tabBarItem.image = UIImage(named: "tabbar-activities.png")
        
        schamperController.tabBarItem.image = UIImage(named: "tabbar-schamper.png")
        
        newsViewController.tabBarItem.image = UIImage(named: "tabbar-news.png")
        
        urgentController.tabBarItem.title = "Urgent"
        urgentController.tabBarItem.image = UIImage(named: "tabbar-urgent.png")
        
        prefsController.tabBarItem.title = "Instellingen"
        prefsController.tabBarItem.image = UIImage(named: "tabbar-settings.png")
        
        var viewControllers = self.viewControllers

        viewControllers?.extend([restoController, infoController, activityController, newsViewController, schamperController, urgentController, prefsController])
        
        self.viewControllers = viewControllers
        
        
        self.tabBar.translucent = false
    }
}