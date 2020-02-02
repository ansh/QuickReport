//
//  SimpleAlertService.swift
//  CompSim
//
//  Created by Rami Sbahi on 12/30/19.
//  Copyright © 2019 Rami Sbahi. All rights reserved.
//

import Foundation
import UIKit

class NotificationAlertService
{
    
    // keyboard: 0 = decimal, 1 = text
    func alert(myTitle: String, success: Bool) -> NotificationAlertViewController
    {
        let storyboard = UIStoryboard(name: "NotificationAlert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "NotificationAlertVC") as! NotificationAlertViewController
        alertVC.myTitle = myTitle
        alertVC.success = success
        return alertVC
    }
}
