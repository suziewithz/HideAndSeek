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
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    
    var mapPinPoint: GMSMarker!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

    }


}

