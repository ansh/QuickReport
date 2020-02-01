//
//  DetailViewController.swift
//  QuickReport
//
//  Created by Rami Sbahi on 2/1/20.
//  Copyright © 2020 Rami Sbahi. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController {
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways){

              currentLocation = locManager.location
              print(currentLocation.coordinate.latitude)
              print(currentLocation.coordinate.longitude)

        }
        
        getPlacemark(forLocation: currentLocation) {
            (originPlacemark, error) in
                print("we are here!")
                if let err = error
                {
                    print(err)
                }
                else if let pm = originPlacemark
                {
                    var addressString : String = ""
                    
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + "\n" // address
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", " // city
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.administrativeArea! + ", " // state
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + "\n" // zip code
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.country! + " "
                    }
                    
                    print(InitialViewController.chosenIssue + "\n")
                    print(pm.subLocality! + "\n")
                    print(addressString)
                }
        }

        // Do any additional setup after loading the view.
    }
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) in

            if let err = error {
                completionHandler(nil, err.localizedDescription)
            }
            else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first
                {
                    completionHandler(placemark, nil)
                }
                else
                {
                    completionHandler(nil, "Placemark was nil")
                }
            }
            else {
                completionHandler(nil, "Unknown error")
            }
        })

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
