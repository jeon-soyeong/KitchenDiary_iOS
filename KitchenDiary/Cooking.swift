//
//  Cooking.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/21.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class Cooking: NSObject {

    var recipeId: Int
    var recipeName: String
    var imageUrl: String
    
    init?(recipeId: Int, recipeName: String, imageUrl: String) {
        

        guard !recipeName.isEmpty else {
            return nil
        }
        guard !imageUrl.isEmpty else {
            return nil
        }
        
        
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.imageUrl = imageUrl
    }
    
}
