//
//  GeofenceViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 07/04/21.
//

import MapKit
import UIKit
import CoreLocation

enum PreferencesKeys: String {
  case savedItems
}

class GeofenceViewController: UIViewController {
    private let map : MKMapView = {
        let map = MKMapView()
        return map
    }()
    var geofences: [Geofence] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(map)
        title = "Home"
        GeofenceMaanger.shared.getUserLocation(completion: { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else{
                    return
                }
                strongSelf.addMapPin(with: location)
            }

        })
        loadAllGeofence()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    func addMapPin(with location: CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
        map.addAnnotation(pin)
    }
    
    // MARK: Loading and saving functions
    func loadAllGeofence() {
        geofences.removeAll()
        let allGeofences = Geofence.allGeofences()
        allGeofences.forEach { add($0) }
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
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(_ geofence: Geofence) {
        geofences.append(geofence)
      map.addAnnotation(geofence)
      addRadiusOverlay(forGeotification: geofence)
      updateGeotificationsCount()
    }

    func remove(_ geofence: Geofence) {
      guard let index = geofences.firstIndex(of: geofence) else { return }
        geofences.remove(at: index)
      map.removeAnnotation(geofence)
      removeRadiusOverlay(forGeotification: geofence)
      updateGeotificationsCount()
    }

    func updateGeotificationsCount() {
      title = "Geotifications: \(geofences.count)"
      navigationItem.rightBarButtonItem?.isEnabled = (geofences.count < 20)
    }
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geofence: Geofence) {
      map.addOverlay(MKCircle(center: geofence.coordinate, radius: geofence.radius))
    }
    func removeRadiusOverlay(forGeotification geofence: Geofence) {
      // Find exactly one overlay which has the same coordinates & radius to remove
        let overlays = map.overlays
      for overlay in overlays {
        guard let circleOverlay = overlay as? MKCircle else { continue }
        let coord = circleOverlay.coordinate
        if coord.latitude == geofence.coordinate.latitude &&
          coord.longitude == geofence.coordinate.longitude &&
          circleOverlay.radius == geofence.radius {
          map.removeOverlay(circleOverlay)
          break
        }
      }
    }

}
// MARK: - MapView Delegate
extension GeofenceViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeotification"
    if annotation is Geofence {
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        let removeButton = UIButton(type: .custom)
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }
}
