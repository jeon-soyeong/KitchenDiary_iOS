//
//  CookingTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingTableViewCell: UITableViewCell {

    @IBOutlet private weak var cookingName: UILabel!
    @IBOutlet private weak var cookingImage: UIImageView!
    @IBOutlet weak var bookMarkButton: UIButton!
    
    var cooking: Cooking? {
        didSet {
            updateUI()
        }
    }
    var loadCooking: [Cooking]? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let cooking = cooking else {
            return
        }
        cookingName.text = cooking.recipeName
        
        guard let url = URL(string: cooking.imageUrl) else {
            return
        }
        if let data = try? Data(contentsOf: url) {
            cookingImage.image = UIImage(data: data)
        }
        
        guard let loadCooking = loadCooking else {
            return
        }
        
        bookMarkButton.isSelected = loadCooking.contains(where: { (loadCooking) -> Bool in
            return cooking.recipeId == loadCooking.recipeId
        })
        
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
