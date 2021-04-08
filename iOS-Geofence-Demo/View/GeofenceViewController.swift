//
//  GeofenceViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 07/04/21.
//

import MapKit
import UIKit
import CoreLocation



class GeofenceViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        let locationBarButtonItem = UIBarButtonItem(title: "Location", style: .done, target: self, action: #selector(zoomToCurrentLocation(sender:)))
            self.navigationItem.leftBarButtonItem  = locationBarButtonItem
        
        GeofenceManager.shared.getUserLocation(completion: { [weak self] location in
            DispatchQueue.main.async {
                guard let strongSelf = self else{
                    return
                }

//                strongSelf.addMapPin(with: location)
                //Manual Loaction update
                let location1: CLLocation = CLLocation(latitude: 37.3349285,
                  longitude: -122.011033)
                let location2: CLLocation = CLLocation(latitude: 37.422,
                  longitude: -122.084058)
                
                strongSelf.addMapPin(with: location1)
                strongSelf.addMapPin(with: location2)
            }

        })
        
        GeofenceManager.shared.delegate = self
        
    }

    func addMapPin(with location: CLLocation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        map.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
        map.addAnnotation(pin)
        map.zoomToLocation(self.map.userLocation.location)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "addGeofence",
        let navigationController = segue.destination as? UINavigationController,
        let addVC = navigationController.viewControllers.first as? AddGeofenceViewController {
        addVC.delegate = self
      }
    }
    // MARK: - Other functions
    @objc func zoomToCurrentLocation(sender: AnyObject) {
        map.zoomToLocation(self.map.userLocation.location)
      
        
    }
    func note(from identifier: String) -> String? {
      let geofences = Geofence.allGeofences()
      let matched = geofences.first { $0.identifier == identifier }
      return matched?.note
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
      // Delete geofence
      guard let geofence = view.annotation as? Geofence else { return }
        GeofenceManager.shared.stopMonitoring(geofence: geofence)
     
        GeofenceManager.shared.removeGeofence(geofence)
        GeofenceManager.shared.saveAllGeofence()
    }
}
// MARK: - Geofence Delegate
extension GeofenceViewController : GeofenceDelegate{

    
    func addAnotation(geofence: Geofence) {
        map.addAnnotation(geofence)
    
    }
    func removeAnotation(geofence: Geofence) {
        map.removeAnnotation(geofence)
    }

    func didEnterGeofence(region : CLCircularRegion) {
        Log.d(region.identifier)
        guard let message = note(from: region.identifier) else { return }
        showAlert(withTitle: "alert", message: message)
    }
    func didExitGeofence(region : CLCircularRegion) {
        guard let message = note(from: region.identifier) else { return }
        showAlert(withTitle: "alert", message: message)
    }
    
}
extension MKMapView {
  func zoomToLocation(_ location: CLLocation?) {
    guard let coordinate = location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
    setRegion(region, animated: true)
  }
}
// MARK: AddGeofenceViewControllerDelegate
extension GeofenceViewController: AddGeofenceViewControllerDelegate {
    func addGeofenceViewController(_ controller: AddGeofenceViewController, didAddGeofence geofence: Geofence) {
        controller.dismiss(animated: true, completion: nil)
        geofence.clampRadius(maxRadius:
        GeofenceManager.shared.locationManager.maximumRegionMonitoringDistance)
        GeofenceManager.shared.addGeofence(geofence)
        GeofenceManager.shared.startMonitoring(geofence: geofence)
        GeofenceManager.shared.saveAllGeofence()
    }
}
