//
//  CurrentLocationOnMapViewController.swift
//  VTQuest
//
//  Created by Osman Balci on 10/20/17.
//  Copyright © 2017 Osman Balci. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CurrentLocationOnMapViewController: UIViewController {
    
    // Instance variable holding the object reference of the MKMapView object created in the Storyboard
    @IBOutlet var mapView: MKMapView!
    
    // Data set by upstream view controller CurrentLocationViewController
    var mapTypePassed: MKMapType?
    var latitudePassed: Double?
    var longitudePassed: Double?
    
    // The amount of north-to-south distance (measured in meters) to use for the span.
    let latitudinalSpanInMeters: Double = 804.672    // = 0.5 mile
    
    // The amount of east-to-west distance (measured in meters) to use for the span.
    let longitudinalSpanInMeters: Double = 804.672   // = 0.5 mile
    
    /*
     -----------------------
     MARK: - View Life Cycle
     -----------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Current Location"
        
        //-----------------------------
        // Dress up the map view object
        //-----------------------------
        
        mapView.mapType = mapTypePassed!
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = false
        
        // Address Center Geolocation
        let addressCenterLocation = CLLocationCoordinate2D(latitude: latitudePassed!, longitude: longitudePassed!)
        
        // Define map's visible region
        let addressMapRegion: MKCoordinateRegion? = MKCoordinateRegionMakeWithDistance(addressCenterLocation, latitudinalSpanInMeters, longitudinalSpanInMeters)
        
        // Set the mapView to show the defined visible region
        mapView.setRegion(addressMapRegion!, animated: true)
        
        //*************************************
        // Prepare and Set Address Annotation
        //*************************************
        
        // Instantiate an object from the MKPointAnnotation() class and place its obj ref into local variable annotation
        let annotation = MKPointAnnotation()
        
        // Dress up the newly created MKPointAnnotation() object
        annotation.coordinate = addressCenterLocation
        annotation.title = "Current Location"
        annotation.subtitle = "Go Hokies!"
        
        // Add the created and dressed up MKPointAnnotation() object to the map view
        mapView.addAnnotation(annotation)
    }
    
}

