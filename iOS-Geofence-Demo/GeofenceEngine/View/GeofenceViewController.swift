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
