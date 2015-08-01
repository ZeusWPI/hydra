//
//  LocationService.swift
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 01/08/15.
//  Copyright © 2015 Zeus WPI. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let sharedService = LocationService()
    
    public var allowedLocation: Bool = false
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var location: CLLocation?
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.distanceFilter = 100.0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    public func startUpdating() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.Restricted || status == CLAuthorizationStatus.Denied {
            allowedLocation = false
            return
        } else if status == .NotDetermined {
            if #available(iOS 8.0, *) {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        allowedLocation = true
        
        self.locationManager.startUpdatingLocation()
    }
    
    public func pauseUpdating() {
        self.locationManager.stopUpdatingLocation()
    }
    
    public func calculateDistance(latitude: Double, longitude: Double) -> CLLocationDistance? {
        if !allowedLocation || location == nil{
            return nil
        }
        return location?.distanceFromLocation(CLLocation(latitude: latitude, longitude: longitude))
    }
    
    //MARK: - Implement core location delegate methods
    @objc public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("Locations updated")
        
        location = locations[0]
    }
    
    @objc public func locationManagerDidResumeLocationUpdates(manager: CLLocationManager) {
        debugPrint("Resumed location updates")
    }
}