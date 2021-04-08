//
//  GeofenceManager.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 07/04/21.
//

import UIKit
import CoreLocation

protocol GeofenceDelegate : class {
    func didEnterGeofence(region : CLCircularRegion)
    func didExitGeofence(region : CLCircularRegion)
    func addAnotation(geofence : Geofence)
    func removeAnotation(geofence: Geofence)
}
enum PreferencesKeys: String {
  case savedItems
}

class GeofenceManager :NSObject {
    static let shared = GeofenceManager()
    let locationManager = CLLocationManager()
    var completion : (([CLLocation]) -> Void)?
    var managerCompletion : ((CLLocationManager) -> Void)?
    weak var delegate: GeofenceDelegate?
    var geofences: [Geofence] = []
    
    
    public func getUserLocation(completion : @escaping (([CLLocation]) -> Void)){
        self.completion =  completion
//        manager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        loadAllGeofences()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            Log.d("\(locations)")
            completion?(locations)
    }
    
    
    // MARK: Loading and saving functions
    func loadAllGeofences() {
      geofences.removeAll()
        let allGeofences = Geofence.allGeofences()
      allGeofences.forEach { addGeofence($0) }
    }

    public func saveAllGeofence() {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(geofences)
        UserDefaults.standard.set(data,forKey: PreferencesKeys.savedItems.rawValue)
        
      } catch {
        Log.e("error encoding geofences")
      }
    }
    
    //MARK: Functions that update the model/associated views with geofence changes
    
    func addGeofence(_ geofence: Geofence)  {
        geofences.append(geofence)
        delegate?.addAnotation(geofence: geofence)
        
    }
    func removeGeofence(_ geofence: Geofence)  {
        guard let index = geofences.firstIndex(of: geofence) else { return }
        geofences.remove(at: index)
        delegate?.removeAnotation(geofence: geofence)
    }
    

    // MARK: Put monitoring functions below
    public func startMonitoring(geofence: Geofence) {
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
        Log.e("Error")
        return
      }
        let fenceRegion = geofence.region
      locationManager.startMonitoring(for: fenceRegion)

    }

    public func stopMonitoring(geofence: Geofence) {
      for region in locationManager.monitoredRegions {
        guard
          let circularRegion = region as? CLCircularRegion,
          circularRegion.identifier == geofence.identifier
        else { continue }

        locationManager.stopMonitoring(for: circularRegion)
        
      }
    }
    
}
// MARK: - Location Manager Delegate
extension GeofenceManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

      let status = manager.authorizationStatus

      if status != .authorizedAlways {
        let message = """
        Your geofence is saved but will only be activated once you grant
        Geotify permission to access the device location.
        """
        Log.w(message)
      }
    }
    func locationManager(_ manager: CLLocationManager,didEnterRegion region: CLRegion) {
      if region is CLCircularRegion {
        delegate?.didEnterGeofence(region: region as! CLCircularRegion)
//        handleEntryEvent(for: region)
      }
    }

    func locationManager(_ manager: CLLocationManager,didExitRegion region: CLRegion) {
      if region is CLCircularRegion {
        delegate?.didExitGeofence(region: region as! CLCircularRegion)
//        handleExitEvent(for: region)
      }
        
    }
//  func handleExitEvent(for region: CLRegion) {
//    Log.i("Exit Geofence triggered!")
//
//  }
//
//    func handleEntryEvent(for region: CLRegion) {
//      Log.i("Entry Geofence triggered!")
//
//    }
    func locationManager(_ manager: CLLocationManager,monitoringDidFailFor region: CLRegion?,withError error: Error) {
      guard let region = region else {
        
        Log.e("Monitoring failed for unknown region")
        return
      }
        Log.e("Monitoring failed for region with identifier: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.e("Location Manager failed with the following error: \(error)")
    }
    
  
}

