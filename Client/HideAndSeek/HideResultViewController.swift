//
//  HideResultViewController.swift
//  HideAndSeek
//
//  Created by suz on 2/16/15.
//  Copyright (c) 2015 suz. All rights reserved.
//

import UIKit

class HideResultViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var selectedFileLabel: UILabel!
    
    var selectedFile : String!
    
    var mapPinPoint: GMSMarker!
    let locationManager = CLLocationManager()
    
    @IBAction func backToRoot(unwindSegue: UIStoryboardSegue) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        selectedFileLabel.text = selectedFile
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        locationManager.stopUpdatingLocation()
        
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
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation! {
            
            // 6
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 7
            locationManager.stopUpdatingLocation()
        }
    }
    
    
}
