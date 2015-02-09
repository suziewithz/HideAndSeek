//
//  AppDelegate.swift
//  HideAndSeek
//
//  Created by suz on 2015. 2. 5..
//  Copyright (c) 2015년 suz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    // 1
    let googleMapsApiKey = "AIzaSyCmzmHCGy2Mb4wET749QYD1iy10iRUeD4Q"
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // 2
        GMSServices.provideAPIKey(googleMapsApiKey)
        return true
    }
}

