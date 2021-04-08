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


class GeofenceManager :NSObject {
    static let shared = GeofenceManager()
    let locationManager = CLLocationManager()
    var completion : ((CLLocation) -> Void)?
    var managerCompletion : ((CLLocationManager) -> Void)?
    weak var delegate: GeofenceDelegate?
    var geofences: [Geofence] = []
    
    public func getUserLocation(completion : @escaping ((CLLocation) -> Void)){
        self.completion =  completion
//        manager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        loadAllGeofences()

    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("New location is \(location)")
            

            completion?(location)
        }
    }
    
    
    // MARK: Loading and saving functions
    func loadAllGeofences() {
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
//        addRadiusOverlay(forGeotification: geofences)
//        updateGeotificationsCount()
        
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
        Your geotification is saved but will only be activated once you grant
        Geotify permission to access the device location.
        """
        print("warning!")
//        showAlert(withTitle: "Warning", message: message)
      }
    }
    func locationManager(_ manager: CLLocationManager,
      didEnterRegion region: CLRegion
    ) {
      if region is CLCircularRegion {
        handleEvent(for: region)
      }
        
       
        delegate?.didEnterGeofence(region: region as! CLCircularRegion)
    }

    func locationManager(_ manager: CLLocationManager,
      didExitRegion region: CLRegion
    ) {
      if region is CLCircularRegion {
        handleEvent(for: region)
      }
        delegate?.didExitGeofence(region: region as! CLCircularRegion)
    }
  func handleEvent(for region: CLRegion) {
      print("Geofence triggered!")
    

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

