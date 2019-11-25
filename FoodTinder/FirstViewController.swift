//
//  FirstViewController.swift
//  FoodTinder
//
//  Created by Caio Gomes on 19/11/19.
//  Copyright © 2019 Zurpei. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {
    let ref = Database.database().reference(withPath: "menu")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

