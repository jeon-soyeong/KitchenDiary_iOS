//
//  ViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/16.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // tabBar 이동
    @IBAction func goToMyKitchen(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
