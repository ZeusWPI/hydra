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

        let newsViewController = UINavigationController(rootViewController: NewsViewController()) // find way without instantiating view controllers
        let activityController = UINavigationController(rootViewController: ActivitiesController())
        let restoController = UINavigationController(rootViewController: RestoMenuController())
        let infoController = UINavigationController(rootViewController: InfoViewController())
        let schamperController = UINavigationController(rootViewController: SchamperViewController())
        let prefsController = UINavigationController(rootViewController: PreferencesController())
        let urgentController = UrgentViewController()
        
        update(restoController.tabBarItem, title: "Resto Menu", image: "resto", tag: 230)
        update(infoController.tabBarItem, title: nil, image: "info", tag: 231)
        update(activityController.tabBarItem, title: nil, image: "activities", tag: 232)
        update(schamperController.tabBarItem, title: nil, image: "schamper", tag: 233)
        update(newsViewController.tabBarItem, title: nil, image: "news", tag: 234)
        update(urgentController.tabBarItem, title: "Urgent.fm", image: "urgent", tag: 235)
        update(prefsController.tabBarItem, title: "Instellingen", image: "settings", tag: 236)
        
        var viewControllers = self.viewControllers!
        viewControllers.extend([restoController, infoController, activityController, newsViewController, schamperController, urgentController, prefsController])
        
        
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
        orderedViewControllers.extend(oldViewControllers)
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
    
    // MARK: TabBarItem functions
    func update(tabBarItem: UITabBarItem, title: String?, image: String, tag: Int) {
        if let t = title {
            tabBarItem.title = t
        }
        tabBarItem.image = UIImage(named: "tabbar-" + image + ".png")
        tabBarItem.tag = tag
    }
}