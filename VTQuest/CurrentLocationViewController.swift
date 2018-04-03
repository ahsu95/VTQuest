//
//  CurrentLocationViewController.swift
//  VTQuest
//
//  Created by Osman Balci on 10/20/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // Instance variables holding the object references of the UI objects created in the Storyboard
    @IBOutlet var mapTypeSegmentedControl: UISegmentedControl!
    
    // Data to pass to downstream view controller CurrentLocationOnMapViewController
    var mapTypeToPass: MKMapType?
    var latitudeToPass: Double?
    var longitudeToPass: Double?
    
    // Instantiate a CLLocationManager object
    var locationManager = CLLocationManager()
    
    var userAuthorizedLocationMonitoring = false
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         IMPORTANT NOTE: Current GPS location cannot be determined under the iOS Simulator
         on your laptop or desktop computer because those computers do NOT have a GPS antenna.
         Therefore, do NOT expect the code herein to work under the iOS Simulator!
         
         You must deploy your location-aware app to an iOS device to be able to test it properly.
         
         To develop a location-aware app:
         
         (1) Link to CoreLocation.framework in your Xcode project
         (2) Include "import CoreLocation" to use its classes.
         (3) Study documentation on CLLocation, CLLocationManager, and CLLocationManagerDelegate
         */
        
        /*
         The user can turn off location services on an iOS device in Settings.
         First, you must check to see of it is turned off or not.
         */
        
        if !CLLocationManager.locationServicesEnabled() {
            showAlertMessage(messageHeader: "Location Services Disabled!",
                             messageBody: "Turn Location Services On in your device settings to be able to use location services!")
            return
        }
        
        /*
         Monitoring the user's current location is a serious privacy issue!
         You are required to get the user's permission in two ways:
         
         (1) requestWhenInUseAuthorization:
         (a) Ask your locationManager to request user's authorization while the app is being used.
         (b) Add a new row in the Info.plist file for "Privacy - Location When In Use Usage Description", for which you specify, e.g.,
         "VTQuest requires monitoring your location only when you are using the app!"
         
         (2) requestAlwaysAuthorization:
         (a) Ask your locationManager to request user's authorization even when the app is not being used.
         (b) Add a new row in the Info.plist file for "Privacy - Location Always Usage Description", for which you specify, e.g.,
         "VTQuest requires monitoring your location even when you are not using your app!"
         
         You select and use only one of these two options depending on your app's requirement.
         */
        
        // We will use Option 1: Request user's authorization while the app is being used.
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            userAuthorizedLocationMonitoring = false
        } else {
            userAuthorizedLocationMonitoring = true
        }
        
        // Set Roadmap as the default map type
        mapTypeSegmentedControl.selectedSegmentIndex = 0
    }
    
    /*
     -------------------------------------------
     MARK: - Show User's Current Location on Map
     -------------------------------------------
     */
    
    // This method is invoked when the user taps the "Show My Current Location on Map" button
    @IBAction func showCurrentLocationOnMap(_ sender: UIButton) {
        print("Button Has been tapped!!!")
        if !userAuthorizedLocationMonitoring {
            
            // User does not authorize location monitoring
            showAlertMessage(messageHeader: "Authorization Denied!",
                             messageBody: "Unable to determine current location!")
            return
        }
        
        // Set the current view controller to be the delegate of the location manager object
        locationManager.delegate = self
        
        // Set the location manager's distance filter to kCLDistanceFilterNone implying that
        // a location update will be sent regardless of movement of the device
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        // Set the location manager's desired accuracy to be the best
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start the generation of updates that report the user’s current location.
        // Implement the CLLocationManager Delegate Methods below to receive and process the location info.
        
        locationManager.startUpdatingLocation()
    }
    
    /*
     ------------------------------------------
     MARK: - CLLocationManager Delegate Methods
     ------------------------------------------
     */
    // Tells the delegate that a new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        /*
         The objects in the given locations array are ordered with respect to their occurrence times.
         Therefore, the most recent location update is at the end of the array; hence, we access the last object.
         */
        let lastObjectAtIndex = locations.count - 1
        let currentLocation: CLLocation = locations[lastObjectAtIndex] as CLLocation
        
        // Obtain current location's latitude in degrees
        latitudeToPass = currentLocation.coordinate.latitude
        
        // Obtain current location's longitude in degrees
        longitudeToPass = currentLocation.coordinate.longitude
        
        // Stops the generation of location updates since we do not need it anymore
        manager.stopUpdatingLocation()
        
        // To make sure that it really stops updating the location, set its delegate to nil
        locationManager.delegate = nil
        
        switch mapTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            mapTypeToPass = MKMapType.standard
        case 1:
            mapTypeToPass = MKMapType.satellite
        case 2:
            mapTypeToPass = MKMapType.hybrid
        default:
            return
        }
        
        performSegue(withIdentifier: "My Current Location", sender: self)
    }
    
    /*
     ------------------------
     MARK: - Location Manager
     ------------------------
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // Stops the generation of location updates since error occurred
        manager.stopUpdatingLocation()
        
        // To make sure that it really stops updating the location, set its delegate to nil
        locationManager.delegate = nil
        
        showAlertMessage(messageHeader: "Unable to Locate You!",
                         messageBody: "An error occurred while trying to determine your location: \(error.localizedDescription)")
        return
    }
    
    /*
     -----------------------------
     MARK: - Display Alert Message
     -----------------------------
     */
    func showAlertMessage(messageHeader header: String, messageBody body: String) {
        
        /*
         Create a UIAlertController object; dress it up with title, message, and preferred style;
         and store its object reference into local constant alertController
         */
        let alertController = UIAlertController(title: header, message: body, preferredStyle: UIAlertControllerStyle.alert)
        
        // Create a UIAlertAction object and add it to the alert controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    /*
     -------------------------
     MARK: - Prepare for Segue
     -------------------------
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "My Current Location" {
            
            // Obtain the object reference of the destination (downstream) view controller
            let currentLocationOnMapViewController: CurrentLocationOnMapViewController = segue.destination as! CurrentLocationOnMapViewController
            
            // Pass the following data to downstream view controller CurrentLocationOnMapViewController
            currentLocationOnMapViewController.mapTypePassed = mapTypeToPass
            currentLocationOnMapViewController.latitudePassed = latitudeToPass
            currentLocationOnMapViewController.longitudePassed = longitudeToPass
        }
    }
    
}


