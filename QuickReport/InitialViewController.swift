//
//  InitialViewController.swift
//  QuickReport
//
//  Created by Rami Sbahi on 2/1/20.
//  Copyright © 2020 Rami Sbahi. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var RetakeButton: UIButton!
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var IssueSelector: UISegmentedControl!
    @IBOutlet weak var TextLabel: UILabel!
    
    static var image: UIImage!
    
    var imagePicker: UIImagePickerController!
    var model: NewModel!
    
    static var chosenIssue = ""
    static var address = ""
    
    var currentIssueIndex = -1
    
    let myShortenedIssues = ["Pothole", "Litter", "Fallen Tree", "Sidewalk Repair", "Graffiti"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        model = NewModel()
        
        
        // Do any additional setup after loading the view.
    }
    

    
    func successNotification(alertMessage: String, success: Bool)
    {
        print("in notification")
        let alertService = NotificationAlertService()
        let alert = alertService.alert(myTitle: alertMessage, success: success)
        self.present(alert, animated: true, completion: nil)
        // ask again - no input
    }
    
    func showButtons()
    {
        imageView.isHidden = false
        NextButton.isHidden = false
        RetakeButton.isHidden = false
        IssueSelector.isHidden = false
        Logo.isHidden = true
        TextLabel.isHidden = true
        CameraButton.isHidden = true
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        performSegue(withIdentifier: "nextSegue", sender: self)
    }
    
    @IBAction func cameraPressed(_ sender: Any) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage // retrieve image
        
        // Converts image into 299x299 square
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        imageView.draw(CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        InitialViewController.image = newImage
        UIGraphicsEndImageContext()
           
        
        // convert into CVPixelBuffer for our model
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        guard let prediction = try? model.prediction(image__0: pixelBuffer!) else {
            return
        }
         
        
        let myMap = ["CICAgICAgL23IBINcG90aG9sZXJlcGFpcg==" : "Pothole", "CICAgICAgP20LRINbGl0dGVycmVtb3ZhbA==" : "Litter", "CICAgICAwJzfHxILZmFsbGVudHJlZXM=" : "Fallen Tree", "CICAgICAgP3UVxIOc2lkZXdhbGtyZXBhaXI=" : "Sidewalk Repair", "CICAgICAgP2UahIIR3JhZmZpdGk=" : "Graffiti"]
        
        let sorted = Array(prediction.scores__0.sorted{$0.1 > $1.1})
        print(sorted)
        
        print(sorted[0])
        
        IssueSelector.selectedSegmentIndex = 0
        
        
        for i in 0...2
        {
            let start = myMap[sorted[i].key]! + " ("
            let percent = round(sorted[i].value*1000.0) / 10.0
            let string = start + String(percent) + "%)"
            IssueSelector.setTitle(string, forSegmentAt: i)
        }
        
        showButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if(FormViewController.transitioned)
        {
            if(FormViewController.success)
            {
                self.successNotification(alertMessage: "Submission successful!", success: true)
            }
            else
            {
                self.successNotification(alertMessage: "Submission failed", success: false)
            }
            FormViewController.transitioned = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let parts = IssueSelector.titleForSegment(at: IssueSelector.selectedSegmentIndex)!.components(separatedBy: " (")
        InitialViewController.chosenIssue = parts[0]
        
    }
    
    override func viewDidLayoutSubviews() {
        for segmentViews in IssueSelector.subviews {
            for segmentLabel in segmentViews.subviews {
                if segmentLabel is UILabel {
                    (segmentLabel as! UILabel).numberOfLines = 0
                }
            }
        }
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
