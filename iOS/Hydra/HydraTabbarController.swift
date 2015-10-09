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
        self.delegate = self

        let newsViewController = UINavigationController(rootViewController: NewsViewController())
        let activityController = UINavigationController(rootViewController: ActivitiesController())
        let infoController = UINavigationController(rootViewController: InfoViewController())
        let schamperController = UINavigationController(rootViewController: SchamperViewController())
        let prefsController = UINavigationController(rootViewController: PreferencesController())
        let urgentController = UrgentViewController()
        
        infoController.tabBarItem.configure(nil, image: "info", tag: 231)
        activityController.tabBarItem.configure(nil, image: "activities", tag: 232)
        schamperController.tabBarItem.configure(nil, image: "schamper", tag: 233)
        newsViewController.tabBarItem.configure(nil, image: "news", tag: 234)
        urgentController.tabBarItem.configure("Urgent.fm", image: "urgent", tag: 235)
        prefsController.tabBarItem.configure("Voorkeuren", image: "settings", tag: 236)

        var viewControllers = self.viewControllers!
        viewControllers.appendContentsOf([infoController, activityController, newsViewController, schamperController, urgentController, prefsController])
        
        self.viewControllers = orderViewControllers(viewControllers)
        
        // Fix gray tabbars
        self.tabBar.translucent = false
    }
    
    func orderViewControllers(viewControllers: [UIViewController]) -> [UIViewController]{
        let tagsOrder = PreferencesService.sharedService().hydraTabBarOrder as! [Int]
        if tagsOrder.count == 0 {
            return viewControllers
        }
        
        var orderedViewControllers = [UIViewController]()
        var oldViewControllers = viewControllers

        for tag in tagsOrder {
            let controller_index: Int? = oldViewControllers.indexOf({ (el) -> Bool in
                el.tabBarItem.tag == tag
            })
            if let index = controller_index {
                orderedViewControllers.append(oldViewControllers.removeAtIndex(index))
            }
        }
        
        // Add all other viewcontrollers, it's possible new ones are added
        orderedViewControllers.appendContentsOf(oldViewControllers)
        return orderedViewControllers
    }
    
    // MARK: UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didEndCustomizingViewControllers viewControllers: [UIViewController], changed: Bool) {
        debugPrint("didEndCustomizingViewControllers called")
        if !changed {
            return
        }
        
        var tagsOrder = [Int]()
        for controller in viewControllers {
            tagsOrder.append(controller.tabBarItem.tag)
        }
        
        PreferencesService.sharedService().hydraTabBarOrder = tagsOrder
    }
}

// MARK: UITabBarItem functions
extension UITabBarItem {
    
    // Configure UITabBarItem with string, image and tag
    func configure(title: String?, image: String, tag: Int) {
        if let title = title {
            self.title = title
        }
        self.image = UIImage(named: "tabbar-" + image + ".png")
        self.tag = tag
    }
}