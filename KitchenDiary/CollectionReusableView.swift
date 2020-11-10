//
//  CollectionReusableView.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/10.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import FSCalendar

class CollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var selectDate: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    let dateFormatter = DateFormatter()
    
}
extension CollectionReusableView: FSCalendarDelegate, FSCalendarDataSource {
   
    func updateUI() {
        guard let calendar = calendar else {
            return
        }
        calendar.delegate = self
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont(name: "KoreanPGSB", size: 23)!
        calendar.appearance.weekdayTextColor = UIColor.black
        calendar.appearance.selectionColor = UIColor.black
        calendar.locale = Locale(identifier: "ko_KR")
        
        dateFormatter.dateFormat = "MM월 dd일 ▼"
        let selectDateString = dateFormatter.string(from: Date())
        selectDate.setTitle(selectDateString, for: .normal)
    }
    
    @IBAction func calendarToggle(_ sender: Any) {
        if calendar.scope == FSCalendarScope.month {
            calendar.scope = .week
            calendar.setScope(.week, animated: true)
        } else {
            calendar.scope = .month
            calendar.setScope(.month, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "MM월 dd일 ▼"
        let selectDateString = dateFormatter.string(from: date)
        selectDate.setTitle(selectDateString, for: .normal)
    }
}
