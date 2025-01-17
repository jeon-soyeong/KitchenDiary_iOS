//
//  IngredientTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/15.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

public class IngredientTableViewCell: UITableViewCell {
    @IBOutlet weak var ingredientsName: UILabel!
    @IBOutlet weak var storageMethod: UILabel!
    @IBOutlet weak var expirationDate: UILabel!
    @IBOutlet weak var ingredientsMemo: UILabel!
    @IBOutlet weak var warning: UIImageView!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
