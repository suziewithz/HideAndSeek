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
    
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var seekButton: UIButton!
    
    
    @IBAction func hideButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("PushDataToHide", sender: self)
    }
    
    @IBAction func seekButtonPressed(sender: AnyObject) {
    }
    
    var mapPinPoint: GMSMarker!
    let locationManager = CLLocationManager()
    
    var xCoordinate : Double!
    var yCoordinate : Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        xCoordinate = locationManager.location.coordinate.latitude
        yCoordinate = locationManager.location.coordinate.longitude
        
        latitudeLabel.text = "Latitude : \(xCoordinate)"
        longitudeLabel.text = "Longitude: \(yCoordinate)"
        
        
        
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
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier :NSString! = segue.identifier
        if identifier.isEqualToString("PushDataToHide") {
            let viewController :HideViewController! = segue.destinationViewController as HideViewController
            viewController.xCoordinate = self.xCoordinate
            viewController.yCoordinate = self.yCoordinate
        }
        if identifier.isEqualToString("PushDataToSeek") {
            let viewController :HideViewController! = segue.destinationViewController as HideViewController
            viewController.xCoordinate = self.xCoordinate
            viewController.yCoordinate = self.yCoordinate
        }
    }
}

