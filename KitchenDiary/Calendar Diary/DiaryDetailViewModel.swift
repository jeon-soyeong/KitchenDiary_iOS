//
//  DiaryDetailViewModel.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/23.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation

class DiaryDetailViewModel {
    var cookingDiary: CookingDiary?
    func update(model: CookingDiary?) {
        cookingDiary = model
    }
}
