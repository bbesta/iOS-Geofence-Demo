
# iOS-Geofence-Demo
Setup Geofences and get notifications when the device enters or leaves the geofence.

## Instructions / Testing
 - Clone The Repo.
 - Build in Xcode; run on Simulator.
 - Use the included SimulatedLocations.gpx file with the Simulate Location.
 -  To test in simulator you can use .GPX file (add GPX file file-> new -> under resource section there will option of GPX file)
 - For using GPX file when app is running in simulator there is option in xCode (debug -> simulate location -> select your GPX file)



## Technical Design Note
Below is a high level technical design diagram:

￼<p align="center">
<img alt="WoosmapGeofencing" src="https://github.com/bbesta/iOS-Geofence-Demo/blob/main/README.rtfd/Screenshot%202021-04-08%20at%202.58.49%20PM.png" width="80%">
</p>

The GeoFence App  includes modules :
- ### 1.Geofence Engine
- ### 2.Utilities
- ### 3.Logger



# Geofence Engine
This is heart of the app, a reusable module decoupled from view and view models.
 - Geofence, a model class representing the geofence, consists of name, lat, long and radius.
 - GeofenceManager, this is responsible for all business logic to manage the geofences. CorelocationManager is part of this class.
- GeofenceManagerDelegate, a protocol with set of interfaces; a delegate can confirm to this protocol and get the fence entry/exit events.

# Logger
The Logger is a helper class to print/console/write to DB/3rd party services, all the logs from the app.
