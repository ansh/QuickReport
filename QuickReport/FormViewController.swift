//
//  FormViewController.swift
//  QuickReport
//
//  Created by Ansh Nanda on 2/1/20.
//  Copyright © 2020 Rami Sbahi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts



extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class FormViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var pinView: MKAnnotationView!

    @IBOutlet weak var issueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var parkLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var issueText: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var parkText: UITextView!
    @IBOutlet weak var addressText: UITextView!
    
    @IBOutlet weak var MapView: MKMapView!
    
    @IBOutlet weak var LocationStackView: UIStackView!
    
    static var success = false
    static var transitioned = false
    
    var usingPark: Bool!
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("called map view view for annotation")
        let reuseId = "myAnnotation"
        
        pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        
        //
        pinView!.canShowCallout = true
        pinView!.isDraggable = true
        
        
        
        return pinView
        
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        print("called")
        
        if newState == MKAnnotationView.DragState.ending {
            if let coordinate = view.annotation?.coordinate {
                
                //  let coordinate = view.annotation?.coordinate
                print(coordinate.latitude)
                //allmapView.removeAnnotations(allmapView.annotations)
                
                currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: nil)
                
                { (clPlacemark: [CLPlacemark]?, error: Error?) in
                    guard let place = clPlacemark?.first else {
                        print("No placemark from Apple: \(String(describing: error))")
                        return
                    }

                    let postalAddressFormatter = CNPostalAddressFormatter()
                    postalAddressFormatter.style = .mailingAddress
                    var addressString: String?
                    if let postalAddress = place.postalAddress {
                        addressString = postalAddressFormatter.string(from: postalAddress)
                    }
                    self.addressText.text = addressString
                    InitialViewController.address = addressString ?? " "
                    
                }
                
                getPlacemark(forLocation: currentLocation) {
                    (originPlacemark, error) in
                        if let err = error
                        {
                            print(err)
                        }
                        else if let pm = originPlacemark
                        {
                            self.parkText.text = pm.subLocality ?? " "
                        }
                }
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        usingPark = ["Graffiti", "Litter", "Fallen Tree"].contains(InitialViewController.chosenIssue)
        
        if(!usingPark)
        {
            LocationStackView.isHidden = true
        }
    }
    
    func createImageRequest()
    {
        var semaphore = DispatchSemaphore (value: 0)
        
        let image : UIImage = InitialViewController.image!
        let imageData:NSData = image.pngData()! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)

        

        let parameters = [
          [
            "key": "image",
            "value": strBase64,
            "type": "text"
          ]] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var error: Error? = nil
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            } else {
              let paramSrc = param["src"] as! String
              let fileData = try! NSData(contentsOfFile:paramSrc, options:[]) as Data
                
              let fileContent = String(data: fileData, encoding: .utf8)!
              body += "; filename=\"\(paramSrc)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!,timeoutInterval: Double.infinity)
        request.addValue("Client-ID 546c25a59c58ad7", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print("IMGUR SHIT")
            print(String(describing: error))
            return
          }
        print("IMGUR SHIT")
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
        
    }
    
    func loadImage()
    {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load called")
        
        usingPark = ["Graffiti", "Litter", "Fallen Tree"].contains(InitialViewController.chosenIssue)
        
        createImageRequest()
        
        
        
        
        if(!usingPark)
        {
            LocationStackView.isHidden = true
        }
        
        for textView in [issueText, descriptionText, parkText, addressText]
        {
            textView!.delegate = self
            textView!.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            textView!.layer.borderWidth = 1
            textView!.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        descriptionText.delegate = self
        parkText.delegate = self
        addressText.delegate = self
        
        issueText.isEditable = false
        
        for label in [issueLabel, descriptionLabel, parkLabel, addressLabel]
        {
            label!.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            label!.layer.cornerRadius = 8
            label!.layer.borderWidth = 1
            label!.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        locManager.requestWhenInUseAuthorization()
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways){

              currentLocation = locManager.location
              MapView.setCenter(currentLocation!.coordinate, animated: true)
                MapView.mapType = MKMapType.standard

                let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 150, longitudinalMeters: 150)
                MapView.setRegion(region, animated: true)

                let annotation = MKPointAnnotation()
                annotation.coordinate = currentLocation!.coordinate
                annotation.title = InitialViewController.chosenIssue
                annotation.subtitle = descriptionText.text!
                MapView.addAnnotation(annotation)
                MapView.delegate = self
                print(currentLocation.coordinate.latitude)
                print(currentLocation.coordinate.longitude)

        }
        
        CLGeocoder().reverseGeocodeLocation(currentLocation, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }

            let postalAddressFormatter = CNPostalAddressFormatter()
            postalAddressFormatter.style = .mailingAddress
            var addressString: String?
            if let postalAddress = place.postalAddress {
                addressString = postalAddressFormatter.string(from: postalAddress)
            }
            self.addressText.text = addressString
            InitialViewController.address = addressString ?? " "
            
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
                    self.parkText.text = pm.subLocality ?? " "
                }
        }
        
        self.issueText.text = InitialViewController.chosenIssue
        addressText.text = InitialViewController.address.replacingOccurrences(of: "\n", with: " ")
        

        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        print("text changed")
        
        let annotation = MKPointAnnotation()
        MapView.removeAnnotation(MapView.annotations[0])
        annotation.coordinate = currentLocation!.coordinate
        annotation.title = InitialViewController.chosenIssue
        annotation.subtitle = descriptionText.text
        MapView.addAnnotation(annotation)
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
    
    @IBAction func SubmitPressed(_ sender: Any) {
        
        var dict = ["name" : InitialViewController.chosenIssue, "address" : addressText.text.replacingOccurrences(of: "\n", with: " ") , "describe" : descriptionText.text ?? "", "latitude" : String(currentLocation.coordinate.latitude), "longitude" : String(currentLocation.coordinate.longitude)]
        
        if(usingPark) // add park if needed
        {
            dict["park"] = parkText.text ?? ""
        }
        if(InitialViewController.chosenIssue == "Fallen Tree") // add contact if needed
        {
            dict["contact"] = "6137298392"
        }
        
        guard let uploadData = try? JSONEncoder().encode(dict) else {
            return
        }
        
        print(String(data: uploadData, encoding: .utf8)!)
        
        
        createRequest(uploadData: uploadData)
        
        FormViewController.transitioned = true
        
        
        self.performSegue(withIdentifier: "returnToStart", sender: self)
    }
    
    func createRequest(uploadData: Data)
    {
        let url = URL(string: "https://quicker-report.herokuapp.com/form")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if error != nil {
                FormViewController.success = false
                return
            }
            /*print((response as? HTTPURLResponse)?.statusCode ?? -1)
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error ")
                FormViewController.success = false
                return
            }*/
            
            print(response?.mimeType ?? " ")
            if let _ = response?.mimeType,
                let data = data,
                let dataString = String(data: data, encoding: .utf8)
            {
                print ("got data: \(dataString)")
                FormViewController.success = true
            }
        }
        task.resume()
    }
    
    
//    func makeRequest(jsonString: String)
//    {
//        let request: URLRequest
//
//        do {
//            request = try createRequest(jsonString: jsonString)
//        }
//        catch {
//            print(error)
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                // handle error here
//                print(error ?? "Unknown error")
//                return
//            }
//
//
//             DispatchQueue.main.async {
//                 // update your UI and model objects here
//             }
//        }
//        task.resume()
//    }
    
    
    
//    func json(from object:Any) -> String? {
//        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
//            return nil
//        }
//        return String(data: data, encoding: String.Encoding.utf8)
//    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

