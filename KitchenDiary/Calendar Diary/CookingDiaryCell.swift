//
//  CookingDiaryCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/10.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingDiaryCell: UICollectionViewCell {
    @IBOutlet weak var cookingName: UILabel!
    @IBOutlet weak var cookingPhoto: UIImageView!
    @IBOutlet weak var cookingRating: RatingControl!
    @IBOutlet weak var deleteButton: UIButton!
    
    func updateUI(_ cookingDiary: CookingDiary) {
        cookingName.text = cookingDiary.cookingName
        cookingPhoto.image = cookingDiary.cookingPhoto
        cookingRating.rating = cookingDiary.cookingRating
    }
}
