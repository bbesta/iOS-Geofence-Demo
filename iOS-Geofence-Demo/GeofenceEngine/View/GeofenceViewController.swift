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
//    private let map : MKMapView = {
//        let map = MKMapView()
//        return map
//    }()
    @IBOutlet weak var map: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        let locationBarButtonItem = UIBarButtonItem(title: "Location", style: .done, target: self, action: #selector(zoomToCurrentLocation(sender:)))
            self.navigationItem.leftBarButtonItem  = locationBarButtonItem
        
        GeofenceMaanger.shared.getUserLocation(completion: { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else{
                    return
                }
                
                strongSelf.addMapPin(with: location)
            }

        })
        
        
    }

    func addMapPin(with location: CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
        map.addAnnotation(pin)
        map.zoomToLocation(self.map.userLocation.location)
    }
    // MARK: - Other functions
    @objc func zoomToCurrentLocation(sender: AnyObject) {
        map.zoomToLocation(self.map.userLocation.location)
      
        
    }
    

}
// MARK: - MapView Delegate
extension GeofenceViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeofence"
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
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if overlay is MKCircle {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.lineWidth = 1.0
        circleRenderer.strokeColor = .purple
        circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
        return circleRenderer
      }
      return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      // Delete geotification
      guard let geofence = view.annotation as? Geofence else { return }
        GeofenceMaanger.shared.stopMonitoring(geofence: geofence)
     
        GeofenceMaanger.shared.removeGeofence(geofence)
        GeofenceMaanger.shared.saveAllGeofence()
    }
}
// MARK: - Geofence Delegate
extension GeofenceViewController : GeofenceDelegate{
    func updateUserLocation(_ authorization: Bool) {
        map.showsUserLocation = authorization
//        map.zoomToLocation(map.userLocation.location)
    }
    
    
    func addAnotation(geofence: Geofence) {
        map.addAnnotation(geofence)
    
    }
    func removeAnotation(geofence: Geofence) {
        map.removeAnnotation(geofence)
    }
    
    func didStartMontioring() {
        //Required
    }
    
    func didStopMontioring() {
        //Required
    }
    
    func didEnterGeofence(geofence: Geofence) {
        let fenceRegion = geofence.region
        manager.startMonitoring(for: fenceRegion)
    }
    func didExitGeofence(geofence: Geofence) {
        for region in manager.monitoredRegions {
          guard
            let circularRegion = region as? CLCircularRegion,
            circularRegion.identifier == geofence.identifier
          else { continue }

          manager.stopMonitoring(for: circularRegion)
        }
    }
    
}
extension MKMapView {
  func zoomToLocation(_ location: CLLocation?) {
    guard let coordinate = location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
    setRegion(region, animated: true)
  }
}
