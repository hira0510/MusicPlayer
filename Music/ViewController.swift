//
//  ViewController.swift
//  Music
//
//  Created by Hira on 2019/10/18.
//  Copyright © 2019 王一平. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {
    
    @IBOutlet weak var views: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let it = views.items {
            for element in it.enumerated() {
                element.element.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 150/255, green: 50/255, blue: 1, alpha: 1)], for: .selected)
            }
        }
    }


}

