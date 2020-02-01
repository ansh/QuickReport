//
//  PotholeViewController.swift
//  QuickThing
//
//  Created by Rami Sbahi on 11/3/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation

class PotholeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var SizePicker: UIButton!
    @IBOutlet var SizeElements: [UIButton]!
    
    @IBOutlet weak var SafePicker: UIButton!
    @IBOutlet var SafeElements: [UIButton]!
    
    @IBOutlet weak var MultiplePicker: UIButton!
    @IBOutlet var MultipleElements: [UIButton]!
    
    
    
    let sizes = ["Small", "Medium", "Large"]
    let lowerSizes = ["small", "medium-sized", "large"]
    static var sizeIndex: Int = 0
    
    let yesNo = ["Yes", "No"]
    static var safeIndex: Int = 0
    static var multipleIndex: Int = 0
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    
    @IBAction func SizePickerPressed(_ sender: UIButton) {
        
        SizeElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    @IBAction func SizePicked(_ sender: UIButton) {
        SizeElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
        guard let title = sender.currentTitle else
        {
            return
        }
        
        SizePicker.setTitle(title, for: .normal)
        PotholeViewController.sizeIndex = sizes.firstIndex(of: title)!
        print(PotholeViewController.sizeIndex)
        
    }
    
    @IBAction func SafePickerPressed(_ sender: Any) {
        
        SafeElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func SafePicked(_ sender: UIButton) {
        SafeElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
        guard let title = sender.currentTitle else
        {
            return
        }
        
        SafePicker.setTitle(title, for: .normal)
        PotholeViewController.safeIndex = yesNo.firstIndex(of: title)!
        print(PotholeViewController.safeIndex)
    }
    
    @IBAction func MultiplePickerPressed(_ sender: Any) {
        MultipleElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func MultiplePicked(_ sender: UIButton) {
        MultipleElements.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
        guard let title = sender.currentTitle else
        {
            return
        }
        
        MultiplePicker.setTitle(title, for: .normal)
        PotholeViewController.multipleIndex = yesNo.firstIndex(of: title)!
        print(PotholeViewController.multipleIndex)
    }
    
    
    @IBAction func SubmitButton(_ sender: Any) {
        composeEmail()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways){

              currentLocation = locManager.location
              print(currentLocation.coordinate.latitude)
              print(currentLocation.coordinate.longitude)

        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        PotholeViewController.sizeIndex = 0
        PotholeViewController.safeIndex = 0
        PotholeViewController.multipleIndex = 0
        
    }
    
    func composeEmail()
    {
        if(MFMailComposeViewController.canSendMail())
        {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["sbahirami@gmail.com"])
            var avoidance = "can"
            if(PotholeViewController.safeIndex == 1)
            {
                avoidance = "cannot"
            }
            let size = lowerSizes[PotholeViewController.sizeIndex]
            var additionalPotHoles = ""
            if(PotholeViewController.multipleIndex == 0)
            {
                additionalPotHoles = "There are multiple potholes like this in the area. "
            }
            
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            
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
                            addressString = addressString + pm.thoroughfare! + "<br>" // address
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", " // city
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.administrativeArea! + ", " // state
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + "<br>" // zip code
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.country! + " "
                        }
                        mail.setSubject("Pothole Report")
                        mail.setMessageBody("<p>Dear Mr. Thomas Bonfield, <br><br>Hello! I hope you’re doing well. There is a \(size) pothole at \(pm.subLocality ?? "a place near me") at these address and coordinates: <br><br>\(addressString)<br><br>\(self.currentLocation.coordinate.latitude), \(self.currentLocation.coordinate.longitude)<br><br> The pothole \(avoidance) be safely avoided. \(additionalPotHoles)I would greatly appreciate it if a team could be dispatched to fix this issue in the near future.<br><br>Sincerely,<br>A Durham resident<p>", isHTML: true)
                        
                        //let imageData: NSData =
                        //mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "imageName.png")
                        
                        self.present(mail, animated: true)
                    }
            }
                
                //let address = getAddressFromLatLon(pdblLatitude: String(currentLocation.coordinate.latitude), withLongitude: String(currentLocation.coordinate.longitude))
                
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        
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
    
    /*func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)


        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]

                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }


                    print(addressString)
              }
        })

    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
