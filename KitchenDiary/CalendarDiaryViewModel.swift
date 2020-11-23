//
//  CalendarDiaryViewModel.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/23.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation

class CalendarDiaryViewModel {
    var cookingDiaries = [CookingDiary]()
    var numOfCookingDiaries: Int {
        return cookingDiaries.count
    }
    func cookingDiaries(at index: Int) -> CookingDiary {
        return cookingDiaries[index]
    }
}
