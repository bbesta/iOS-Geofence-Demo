//
//  GeofenceManager.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 07/04/21.
//

import UIKit
import CoreLocation

protocol GeofenceDelegate : class {
    func didEnterGeofence(geofence : Geofence)
    func didExitGeofence(geofence : Geofence)
    func didStartMontioring()
    func didStopMontioring()
    func updateUserLocation(_ authorization: Bool)
    func addAnotation(geofence : Geofence)
    func removeAnotation(geofence: Geofence)
}
let manager = CLLocationManager()

class GeofenceMaanger :NSObject {
    static let shared = GeofenceMaanger()
    
    var completion : ((CLLocation) -> Void)?
    var managerCompletion : ((CLLocationManager) -> Void)?
    weak var delegate: GeofenceDelegate?
    
    var geofences: [Geofence] = []
    
    public func getUserLocation(completion : @escaping ((CLLocation) -> Void)){
        self.completion =  completion
//        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.distanceFilter = 100

    }
//    public func getUserLocationManager(completion : @escaping ((CLLocationManager) -> Void)){
//        self.managerCompletion =  completion
//        manager.requestWhenInUseAuthorization()
//        manager.delegate = self
//        manager.startUpdatingLocation()
//        manager.distanceFilter = 100
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("New location is \(location)")
            completion?(location)
            startMonitoring(geotification: geotification)
        }
    }
    func locationManager(_ manager: CLLocationManager,
      didEnterRegion region: CLRegion
    ) {
      if region is CLCircularRegion {
        handleEvent(for: region)
      }
    }

    func locationManager(_ manager: CLLocationManager,
      didExitRegion region: CLRegion
    ) {
      if region is CLCircularRegion {
        handleEvent(for: region)
      }
    }
  func handleEvent(for region: CLRegion) {
      print("Geofence triggered!")
  }
//    func locationManager(_ manager : CLLocationManager, didUpdateLocations locations : [CLLocation]) {
//        guard let location = locations.first else {
//        return
//        }
//        completion?(location)
////        manager.stopUpdatingLocation()
//    }
//    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
//        guard let location = oldLocation else {
//        return
//        }
//        completion?(location)
//    }

    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
      geofences.removeAll()
        let allGeotifications = Geofence.allGeofences()
      allGeotifications.forEach { addGeofence($0) }
    }

    public func saveAllGeofence() {
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
        //Print Error or pass Error
        return
      }
//        let fenceRegion = geofence.region
//      manager.startMonitoring(for: fenceRegion)
        delegate?.didEnterGeofence(geofence: geofence)
    }

    public func stopMonitoring(geofence: Geofence) {
      for region in manager.monitoredRegions {
        guard
          let circularRegion = region as? CLCircularRegion,
          circularRegion.identifier == geofence.identifier
        else { continue }

//        manager.stopMonitoring(for: circularRegion)
        delegate?.didExitGeofence(geofence: geofence)
        
      }
    }
    
}
// MARK: - Location Manager Delegate
extension GeofenceMaanger: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

      let status = manager.authorizationStatus

//      mapView.showsUserLocation = (status == .authorizedAlways)

        delegate?.updateUserLocation(true)
        
      if status != .authorizedAlways {
        let message = """
        Your geotification is saved but will only be activated once you grant
        Geotify permission to access the device location.
        """
        print("warning!")
//        showAlert(withTitle: "Warning", message: message)
      }
    }

    func locationManager(_ manager: CLLocationManager,monitoringDidFailFor region: CLRegion?,withError error: Error) {
      guard let region = region else {
        print("Monitoring failed for unknown region")
        return
      }
      print("Monitoring failed for region with identifier: \(region.identifier)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location Manager failed with the following error: \(error)")
    }
    
  
}
