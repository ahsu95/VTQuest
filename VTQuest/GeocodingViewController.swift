//
//  GeocodingViewController.swift
//  VTQuest
//
//  Created by Osman Balci on 10/20/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class GeocodingViewController: UIViewController {
    
    // Instance variables holding the object references of the UI objects created in the Storyboard
    @IBOutlet var mapTypeSegmentedControl: UISegmentedControl!
    @IBOutlet var addressTextField: UITextField!
    
    // Data to pass to downstream view controller GeocodingMapViewController
    var addressToPass = ""
    var mapTypeToPass: MKMapType?
    var latitudeToPass: Double?
    var longitudeToPass: Double?
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Standard as the default map type
        mapTypeSegmentedControl.selectedSegmentIndex = 0
    }
    
    /*
     ------------------------
     MARK: - IBAction Methods
     ------------------------
     */
    @IBAction func keyboardDone(_ sender: UITextField) {
        
        // Deactivate the Text Field object and remove the Keyboard
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTouch(_ sender: UIControl) {
        
        // Deactivate the Text Field object and remove the Keyboard
        addressTextField.resignFirstResponder()
    }
    
    /*
     ---------------------------
     MARK: - Show Address on Map
     ---------------------------
     */
    
    // This method is invoked when the user taps the "Show the Address on Map" button
    @IBAction func showAddressOnMap(_ sender: UIButton) {
        
        addressToPass = addressTextField.text!
        
        if addressToPass.isEmpty {
            showAlertMessage(messageHeader: "Address Missing!",
                             messageBody: "Please enter an address or a landmark name to show on map!")
            return
        }
        
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
        
        //******************
        // Forward Geocoding
        //******************
        
        // Instantiate a forward geocoder object
        let forwardGeocoder = CLGeocoder()
        
        /*
         Ask the forward geocoder object to
         (a) execute its geocodeAddressString method in a new thread *** asynchronously ***
         (b) determine the geolocation (latitude, longitude) of the given address, and
         (c) give the results to the completion handler function geocoderCompletionHandler running under the main thread.
         */
        forwardGeocoder.geocodeAddressString(addressToPass) { (placemarks, error) in
            self.geocoderCompletionHandler(withPlacemarks: placemarks, error: error)
        }
        
        /*
         "This method submits the specified location data to the geocoding server asynchronously and returns.
         Your completion handler block [i.e., our geocoderCompletionHandler() function] will be executed on the main thread.
         After initiating a forward-geocoding request, do not attempt to initiate another forward- or reverse-geocoding request.
         
         Geocoding requests are rate-limited for each app, so making too many requests in a short period of time
         may cause some of the requests to fail. When the maximum rate is exceeded, the geocoder passes an error object
         with the value network to your completion handler." [Apple]
         
         Due to the asynchronous processing nature, statements after this method may not be executed.
         Therefore, we have to include the performSegue method at the end of the completion handler block.
         *** If you put the performSegue method right here, the code will fail because of asynchronous processing. ***
         */
    }
    
    /*
     ---------------------------------
     MARK: - Process Geocoding Results
     ---------------------------------
     */
    private func geocoderCompletionHandler(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let errorOccurred = error {
            self.showAlertMessage(messageHeader: "Forward Geocoding Unsuccessful!",
                                  messageBody: "Forward Geocoding of the Given Address Failed: (\(errorOccurred))")
            return
        }
        
        var geolocation: CLLocation?
        
        if let placemarks = placemarks, placemarks.count > 0 {
            geolocation = placemarks.first?.location
        }
        
        if let locationObtained = geolocation {
            
            self.latitudeToPass = locationObtained.coordinate.latitude
            self.longitudeToPass = locationObtained.coordinate.longitude
            
        } else {
            self.showAlertMessage(messageHeader: "Location Match Failed!",
                                  messageBody: "Unable to Find a Matching Location!")
            return
        }
        
        performSegue(withIdentifier: "Address", sender: self)
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
        
        if segue.identifier == "Address" {
            
            // Obtain the object reference of the destination (downstream) view controller
            let geocodingMapViewController: GeocodingMapViewController = segue.destination as! GeocodingMapViewController
            
            // Pass the following data to downstream view controller GeocodingMapViewController
            geocodingMapViewController.addressPassed = addressToPass
            geocodingMapViewController.mapTypePassed = mapTypeToPass
            geocodingMapViewController.latitudePassed = latitudeToPass
            geocodingMapViewController.longitudePassed = longitudeToPass
        }
    }
    
}

