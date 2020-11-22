//
//  CookingDiaryTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/30.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingDiaryTableViewCell: UITableViewCell {
    @IBOutlet weak var cookingName: UILabel!
    @IBOutlet weak var cookingPhoto: UIImageView!
    @IBOutlet weak var cookingRating: RatingControl!
    
    var cookingDiary: CookingDiary? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let cookingDiary = cookingDiary else {
            return
        }
        cookingName.text = cookingDiary.cookingName
        cookingPhoto.image = cookingDiary.cookingPhoto
        cookingRating.rating = cookingDiary.cookingRating
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
