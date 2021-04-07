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
    var managerCompletion : ((CLLocationManager) -> Void)?
    
    var geofences: [Geofence] = []
    
    public func getUserLocation(completion : @escaping ((CLLocation) -> Void)){
        self.completion =  completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.distanceFilter = 100
        
    }
    public func getUserLocationManager(completion : @escaping ((CLLocationManager) -> Void)){
        self.managerCompletion =  completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.distanceFilter = 100
        
    }
    
    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations : [CLLocation]) {
        guard let location = locations.first else {
        return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

      let status = manager.authorizationStatus

//      mapView.showsUserLocation = (status == .authorizedAlways)

      if status != .authorizedAlways {
        let message = """
        Your geotification is saved but will only be activated once you grant
        Geotify permission to access the device location.
        """
//        showAlert(withTitle: "Warning", message: message)
      }
    }

    func locationManager(
      _ manager: CLLocationManager,
      monitoringDidFailFor region: CLRegion?,
      withError error: Error
    ) {
      guard let region = region else {
        print("Monitoring failed for unknown region")
        return
      }
      print("Monitoring failed for region with identifier: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location Manager failed with the following error: \(error)")
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
      geofences.removeAll()
        let allGeotifications = Geofence.allGeofences()
      allGeotifications.forEach { addGeofence($0) }
    }

    func saveAllGeotifications() {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(geofences)
        UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems.rawValue)
      } catch {
        print("error encoding geotifications")
      }
    }
    
    //MARK: Functions that update the model/associated views with geofence changes
    
    func addGeofence(_ geofence: Geofence)  {
        geofences.append(geofence)
    }
    func removeGeofence(_ geofence: Geofence)  {
        guard let index = geofences.firstIndex(of: geofence) else { return }
        geofences.remove(at: index)
    }
    
    
    // MARK: Put monitoring functions below
    func startMonitoring(geofence: Geofence) {
      // 1
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
        //Print Error or pass Error
        return
      }

      // 2
        let fenceRegion = geofence.region
      manager.startMonitoring(for: fenceRegion)
    }

    func stopMonitoring(geofence: Geofence) {
      for region in manager.monitoredRegions {
        guard
          let circularRegion = region as? CLCircularRegion,
          circularRegion.identifier == geofence.identifier
        else { continue }

        manager.stopMonitoring(for: circularRegion)
      }
    }
    
}

