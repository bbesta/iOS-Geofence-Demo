# iOS-Geofence-Demo
Setup Geofences and get notifications when the device enters or leaves the geofence.

## Instructions / Testing
 - Clone The Repo.
 - Build in Xcode; run on Simulator.
 - Use the included GoToGameTest.gpx file with the Simulate Location.
 - Go to the Emulator , click on the options menu of the emulator on Bottom Right side . Now in the New Screen click on the Routes Tab (Upper Side on the Map) and after then click on the import gpx button bottom of the map.
 - After Launching the App The GeoFence Test Data Will be Added and then Click on the Play Button on The Extended Control Screen.


## Technical Design Note
The GeoFence App  includes modules :
- ### 1.View
- ### 2.Engine
- ### 3.Util

# View
The View Is Just a Ui with having two parts 
 - The Map
 - The Logger

### Map Is Pointing all the GeoFences with red Marker .
You can Longpress on the Map To Add that Respective Location as Geofence

### The Logger is showing all the entries,exit and messages [Info or Error] with time and index.
eg.
1. Info Entered 26 March 2020 12:21:12

# Engine
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

# Util:
The Util contains two Things  
  - Logger 
  - Util
## Logger:
- This is just a model class and with an enum class 
## Util:
- The Util class is having only one method namely errorMessage just to check the error type .


 #### The Application is also having crashlytics integrated.
