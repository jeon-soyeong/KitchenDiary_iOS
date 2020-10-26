//
//  CookingTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingTableViewCell: UITableViewCell {

    @IBOutlet weak var cookingName: UILabel!
    @IBOutlet weak var cookingImage: UIImageView!

    @IBOutlet weak var bookMarkButton: UIButton!
    
    var cooking: Cooking? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let cooking = cooking else {
            return
        }
        cookingName.text = cooking.recipeName
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
