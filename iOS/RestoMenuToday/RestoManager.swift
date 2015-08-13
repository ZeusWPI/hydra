//
//  RestoManager.swift
//  Hydra
//
//  Created by Simon Schellaert on 12/11/14.
//  Copyright (c) 2014 Simon Schellaert. All rights reserved.
//

import UIKit

let RestoKitErrorDomain = "com.zeus.RestoKit.ErrorDomain"

enum RestoKitError : Int {
    case LoadDataFromFileFailed = -5
    case NoData                 = -7
    case ParseJSONFailed        = -8
}

class RestoManager: NSObject {
    
    // MARK: Initialization
    
    /**
    Returns the shared Resto manager object for the process.

    - returns: The shared RestoManager object.
    */
    class var sharedManager : RestoManager {
        struct Static {
            static let instance : RestoManager = RestoManager()
        }
        return Static.instance
    }
    
    override init() {
        // Limit the disk capacity of the shared URL cache to 4 MB
        NSURLCache.sharedURLCache().diskCapacity = 4 * 1024 * 1024
    }
    
    
    // MARK: Public Methods

    /**
    Clears the shared URL cache, removing all stored cached URL responses.
    */
    func removeCachedResponses() {
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    /**
    Retrieves the menu for the given date in the background and caches it.
    If the menu is already in the cache, the cached menu is used and no request is made.
    
    - parameter date: The date of the menu you want to retrieve.
    
    - parameter completionHandler: A block that is executed on the main queue when the request has succeeded or failed.
                              The optional menu parameter holds the eventually retrieved menu.
                              The optional error parameter holds any error that caused the request to fail.
                              Either the menu or the error is not nil.
    */
    func retrieveMenuForDate(date: NSDate, completionHandler: (menu: Menu?, error: NSError?) -> ()) {
        // Construct the URL for the API request based on the year and week of the given date
        let dateComponents = NSCalendar.currentCalendar().components([.NSWeekOfYearCalendarUnit, .NSYearCalendarUnit], fromDate: date)
        let URL = NSURL(string: "https://zeus.ugent.be/hydra/api/1.0/resto/menu/\(dateComponents.year)/\(dateComponents.weekOfYear).json")
        
        // We're relying on NSURLCache to cache the data for us when the user is offline
        let URLRequest = NSURLRequest(URL: URL!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 0)
        
        NSURLConnection.sendAsynchronousRequest(URLRequest, queue: NSOperationQueue.mainQueue()) {
            (URLResponse, data, error) -> Void in
            
            if error != nil {
                completionHandler(menu: nil, error: error)
            } else {
                if data != nil {
                    do {
                    try completionHandler(self.menuForDate(date, withData: data!))
                    } catch _ {
                        let error = NSError(domain: RestoKitErrorDomain, code: RestoKitError.NoData.rawValue, userInfo: nil)
                        completionHandler(menu: nil, error: error)
                    }
                } else {
                    let error = NSError(domain: RestoKitErrorDomain, code: RestoKitError.NoData.rawValue, userInfo: nil)
                    completionHandler(menu: nil, error: error)
                }
            }
        }
    }
    
    // MARK: Private Methods
    
    /**
    Creates a Menu for the given date based on the given JSON data.
    
    - parameter date: The date of the menu you want to parse.
    - parameter data: The NSData representation of the JSON containing the menu for the given date.
    
    - returns: A tuple consisting of an optional menu and an optional error.
              Either the menu or the error is not nil.
    */
    private func menuForDate(date : NSDate, withData data : NSData) throws -> (menu: Menu?, error : NSError?) {
        let JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject]
        if let JSONDictionary = JSONDictionary {
            // Create a date string from the given date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.stringFromDate(date)
            
            if let JSONMenu = JSONDictionary[dateString] as? [String : AnyObject] {
                var menuItems = [MenuItem]()
                
                let JSONMainMenuItems      = JSONMenu["meat"]       as? [[String : AnyObject]]
                let JSONSoupMenuItems      = JSONMenu["soup"]       as? [[String : AnyObject]]
                let JSONVegetableMenuItems = JSONMenu["vegetables"] as? [String]
                
                if JSONMainMenuItems != nil {
                    for JSONMainMenuItem in JSONMainMenuItems! {
                        let name = JSONMainMenuItem["name"] as! String
                        var type : MenuItemType = .Main
                        
                        // Some soups are also passed as main menu items in the API.
                        // In the app, however, we consider them to be of the type .Soup.
                        if name.rangeOfString("soep ") != nil || name.hasSuffix("soep") {
                            type = .Soup
                        }
                        
                        let menuItem = MenuItem(name: name.sentenceCapitalizedString as String, type: type, price: NSDecimalNumber(euroString: JSONMainMenuItem["price"] as! String))
                        menuItems.append(menuItem)
                    }
                }
                
                if JSONSoupMenuItems != nil {
                    for JSONSoupMenuItem in JSONSoupMenuItems! {
                        let menuItem = MenuItem(name: (JSONSoupMenuItem["name"] as! String).sentenceCapitalizedString as String, type: .Soup, price: NSDecimalNumber(euroString: JSONSoupMenuItem["price"] as! String))
                        menuItems.append(menuItem)
                    }
                }
                
                if JSONVegetableMenuItems != nil {
                    for JSONVegetableMenuItem in JSONVegetableMenuItems! {
                        let menuItem = MenuItem(name: JSONVegetableMenuItem.sentenceCapitalizedString as String, type: .Vegetable, price: nil)
                        menuItems.append(menuItem)
                    }
                }
                
                let menu = Menu(date: date, menuItems: menuItems, open: JSONMenu["open"] as! Bool)
                return (menu, nil)
            } else {
                let menu = Menu(date: date, menuItems: [], open: false)
                return (menu, nil)
            }
            
        }
        return (nil, nil) //TODO: shouldn't be reached, and needs to be rewritten to use standard hydra resto items
    }
}
