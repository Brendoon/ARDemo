//
//  ViewController.swift
//  ARDemo
//
//  Created by Brendoon Ryos on 24/05/17.
//  Copyright © 2017 Brendoon Ryos. All rights reserved.
//

import UIKit
import SceneKit
import CoreLocation
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var arView : ARView!
    var locationManager = CLLocationManager()
    let radius: CLLocationDistance = 10
    var engenharia: CLRegion! = nil
    var mackmobile: CLRegion! = nil
    var labelRegion = UILabel(frame: CGRect(x: 0, y: 0, width: 350, height: 67))
    var labelScore = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 67))
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        engenharia = CLCircularRegion(center: CLLocationCoordinate2DMake(-23.546461409476542, -46.651640608906746), radius: radius, identifier: "Engenharia")
        mackmobile = CLCircularRegion(center: CLLocationCoordinate2DMake(-23.547544233727127, -46.651123613119125), radius: radius, identifier: "MackMobile")
        
        locationManager.startMonitoring(for: engenharia)
        
        // Create ARView
        arView = ARView()
        arView.frame = self.view.bounds
        arView.autoresizingMask  = [ .flexibleWidth, .flexibleHeight ]
        self.view.addSubview(arView)
        self.view.addSubview(labelRegion)
        self.view.addSubview(labelScore)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region.identifier == "Engenharia" {
            labelRegion.text = "Escola de Engenharia"
            arView.setup3D()
            score += 1
            labelScore.text = String(score)
        } else if region.identifier == "MackMobile" {
            labelRegion.text = "MackMobile"
            arView.setup3D()
            score += 1
            labelScore.text = String(score)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Engenharia" {
            labelRegion.text = ""
            arView.stop3D()
        } else if region.identifier == "MackMobile" {
            labelRegion.text = ""
            arView.stop3D()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

