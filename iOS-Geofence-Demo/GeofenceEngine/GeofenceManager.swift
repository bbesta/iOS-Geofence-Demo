//
//  GeofenceManager.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 07/04/21.
//

import UIKit
import CoreLocation
class GeofenceMaanger :NSObject, CLLocationManagerDelegate {
    static let shared = GeofenceMaanger()
    let manager = CLLocationManager()
    var completion : ((CLLocation) -> Void)?
    
    public func getUserLocation(completion : @escaping ((CLLocation) -> Void)){
        self.completion =  completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations : [CLLocation]) {
        guard let location = locations.first else {
        return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
   
}
