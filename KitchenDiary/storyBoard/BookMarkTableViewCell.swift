//
//  BookMarkTableViewCell.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/27.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class BookMarkTableViewCell: UITableViewCell {
    @IBOutlet weak var bookMarkCookingName: UILabel!
    @IBOutlet weak var bookMarkCookingImage: UIImageView!
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
        bookMarkCookingName.text = cooking.recipeName
        
        guard let url = URL(string: cooking.imageUrl) else {
            return
        }
        if let data = try? Data(contentsOf: url) {
            bookMarkCookingImage.image = UIImage(data: data)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
