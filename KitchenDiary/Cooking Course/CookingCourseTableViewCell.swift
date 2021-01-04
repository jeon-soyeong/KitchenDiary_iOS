//
//  CookingCourseTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/23.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingCourseTableViewCell: UITableViewCell {

    @IBOutlet weak var cookingDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
