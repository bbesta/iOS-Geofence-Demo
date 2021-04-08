//
//  AddGeofenceViewController.swift
//  iOS-Geofence-Demo
//
//  Created by Balaji on 08/04/21.
//

import UIKit
import MapKit

protocol AddGeofenceViewControllerDelegate: class {
  func addGeofenceViewController(_ controller: AddGeofenceViewController, didAddGeofence: Geofence)
}

class AddGeofenceViewController: UITableViewController {
  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!
  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!

  weak var delegate: AddGeofenceViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.isEnabled = false
  }

  @IBAction func textFieldEditingChanged(sender: UITextField) {
    let radiusSet = !(radiusTextField.text?.isEmpty ?? true)
    let noteSet = !(noteTextField.text?.isEmpty ?? true)
    addButton.isEnabled = radiusSet && noteSet
  }

  @IBAction func onCancel(sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction private func onAdd(sender: AnyObject) {
    let coordinate = mapView.centerCoordinate
    let radius = Double(radiusTextField.text ?? "") ?? 0
    let identifier = NSUUID().uuidString
    let note = noteTextField.text ?? ""
    let eventType: Geofence.EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
    let geofence = Geofence(
      coordinate: coordinate,
      radius: radius,
      identifier: identifier,
      note: note,
      eventType: eventType)
    delegate?.addGeofenceViewController(self, didAddGeofence: geofence)
  }

  @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToLocation(mapView.userLocation.location)
  }
}

