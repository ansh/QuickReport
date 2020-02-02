//
//  NotificationAlertViewController.swift
//  CompSim
//
//  Created by Rami Sbahi on 1/9/20.
//  Copyright © 2020 Rami Sbahi. All rights reserved.
//

import UIKit

class NotificationAlertViewController: UIViewController
{
    @IBOutlet var NotifView: UIView!
    @IBOutlet var NotifTitle: UILabel!
    
    var myTitle = String()
    var success: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotifTitle.text = myTitle
        NotifView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        NotifView.backgroundColor = success ? .green : .red
    }

    @IBAction func OKPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
