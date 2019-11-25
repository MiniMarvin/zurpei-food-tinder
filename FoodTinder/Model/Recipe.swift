//
//  Recipes.swift
//  FoodTinder
//
//  Created by Rene on 20/11/19.
//  Copyright © 2019 Zurpei. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Recipe {
    
    let ref: DatabaseReference?
    let key: String
    let name: String
    let ingredientes: [String]
    let modoDePreparo: [String]
    let didMatch: Bool
    
}
