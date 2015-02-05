//
//  ViewController.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 5..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit

class ViewController: UIViewController , CLLocationManagerDelegate{


    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var latitudeLabel : UILabel!
    @IBOutlet weak var longitudeLabel : UILabel!
    
    
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    
    var mapPinPoint: GMSMarker!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let currentLatitude : Double = locationManager.location.coordinate.latitude
        let currentLongitude : Double = locationManager.location.coordinate.longitude
        
        latitudeLabel.text = "Latitude : \(currentLatitude)"
        longitudeLabel.text = "Longitude: \(currentLongitude)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            
            // 3
            locationManager.startUpdatingLocation()
            
            //4
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // 5
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            // 6
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 7
            locationManager.stopUpdatingLocation()
        }
    }
}

