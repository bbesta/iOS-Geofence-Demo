
# iOS-Geofence-Demo
Setup Geofences and get notifications when the device enters or leaves the geofence.

## Instructions / Testing
 - Clone The Repo.
 - Build in Xcode; run on Simulator.
 - Use the included SimulatedLocations.gpx file with the Simulate Location.
 -  To test in simulator you can use .GPX file (add GPX file file-> new -> under resource section there will option of GPX file)
 - For using GPX file when app is running in simulator there is option in xCode (debug -> simulate location -> select your GPX file)



## Technical Design Note

￼<p align="center">
<img alt="WoosmapGeofencing" src="https://github.com/bbesta/iOS-Geofence-Demo/blob/main/README.rtfd/Screenshot%202021-04-08%20at%202.58.49%20PM.png" width="30%">
</p>

The GeoFence App  includes modules :
- ### 1.Geofence Engine
- ### 2.Utilities
- ### 3.GPX
- ### 4.logger


# Geofence Engine
The View Is Just a Ui with having two parts 
 - Model
 - View
 - Geofence Manager

### Model is represent the codingkey of objects, represent the MKAnnotation and notification for the region
### View Map Is Pointing all the GeoFences with red Marker .
You can Longpress on the Map To Add that Respective Location as Geofence

### The Logger is showing all the entries,exit and messages [Info or Error] with time and index.
eg.
### Geofence Manager
The Engine is the Logical Part to Manage and Add GeoFence , its having Three Parts
- [FenceManager] 
- [GeoFence] 
- [GeoFenceBroadCastReceiver] 
  
- FenceManager:
> The Job of Fence Manager is to Initialize the GeoFenceClient and using a Fence Obj as Entity to build the GeoFence.
- GeoFence:
> GeoFence is a Single Entity which contains information about geofence
> like (ID: String, lat: Double,long:Double, radius: Float, name:String,transitionTypes: Int) . 
- GeoFenceBroadcastReceiver:
> The job of GBR is to receive the pending intents for every GeoFence location and show it according to the transaction type or error on the UI.


# Utilities:
The Util contains two Things  
  - Show the alert message on view 

## Logger:
- This is just a model class and with an enum class 
### Inspired by:
[Geofence iOS](https://www.raywenderlich.com/5470-geofencing-with-core-location-getting-started)




