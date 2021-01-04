//
//  CookingDiary.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/30.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingDiary: NSObject {
    //MARK: Properties
    var cookingName: String
    var cookingPhoto: UIImage?
    var cookingRating: Int
    var cookingMemo: String
    var cookingIndex: Int
    var todayDate: String

    init?(cookingName: String, cookingPhoto: UIImage?, cookingRating: Int, cookingMemo: String, cookingIndex: Int, todayDate: String) {
        guard !cookingName.isEmpty || !cookingMemo.isEmpty else {
            return nil
        }
        guard (cookingRating >= 0) && (cookingRating <= 5) else {
            return nil
        }
        guard cookingIndex >= 0 else {
            return nil
        }
        self.cookingName = cookingName
        self.cookingPhoto = cookingPhoto
        self.cookingRating = cookingRating
        self.cookingMemo = cookingMemo
        self.cookingIndex = cookingIndex
        self.todayDate = todayDate
    }
    convenience init(cookingName: String, cookingPhoto: UIImage?, cookingRating: Int, cookingMemo: String) {
        self.init(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating:  cookingRating, cookingMemo: cookingMemo)
    }
}
