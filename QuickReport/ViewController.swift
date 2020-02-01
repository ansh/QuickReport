//
//  ViewController.swift
//  QuickThing
//
//  Created by Rami Sbahi on 11/3/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var model: SecondImageClassifier!
    
    var currentIssueIndex = -1
    
    let myShortenedIssues = ["Pothole", "Litter", "Traffic Signs", "Tree Blocks Signs", "Sidewalk Repair", "Graffiti"]
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var IssueCollection: [UIButton]!
    
    @IBOutlet weak var NextButton: UIButton!
    
    
    @IBOutlet weak var IssueButton: UIButton!
    
    @IBAction func issueTapped(_ sender: UIButton) {
        
        IssueCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBAction func individualIssueTapped(_ sender: UIButton) {
        
        IssueCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        
        guard let title = sender.currentTitle else
        {
            return
        }
        
        IssueButton.setTitle(title, for: .normal)
        
        currentIssueIndex = myShortenedIssues.firstIndex(of: title)!
        print(currentIssueIndex)
    }
    
    
    
    @IBAction func takePhoto(_ sender: Any) {
        
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
         
        let myMap = ["CICAgICAgL23IBINcG90aG9sZXJlcGFpcg==" : "Pothole", "CICAgICAgP20LRINbGl0dGVycmVtb3ZhbA==" : "Litter", "CICAgICAgP3kMRIMdHJhZmZpY3NpZ25z" : "Traffic Signs", "CICAgICAgP3EXxIRdHJlZWJsb2NraW5nc2lnbnM=" : "Tree Blocks Signs", "CICAgICAgP3UVxIOc2lkZXdhbGtyZXBhaXI=" : "Sidewalk Repair", "CICAgICAgP2UahIIR3JhZmZpdGk=" : "Graffiti"]
        let issueString = myMap[prediction.classLabel]!
        print("I think this is \(issueString).")
        print(prediction.scores__0)
        
        makeButtonsAppear()
        IssueButton.setTitle(issueString, for: .normal)
        currentIssueIndex = myShortenedIssues.firstIndex(of: issueString)!
        print(currentIssueIndex)
    }
    
    func makeButtonsAppear()
    {
        NextButton.isHidden = false
        IssueButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        model = SecondImageClassifier()
    }

    
    @IBAction func nextTapped(_ sender: Any) {
        if currentIssueIndex == myShortenedIssues.firstIndex(of: "Pothole")
        {
            self.performSegue(withIdentifier: "potholeSegue", sender: nil)
        }
    }
}

