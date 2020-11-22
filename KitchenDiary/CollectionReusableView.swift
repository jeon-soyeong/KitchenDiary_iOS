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
        guard let selectDate = selectDate else {
            return
        print("selectDate nil)")
        }
        print("selectDate : \(selectDate)")
        
        calendar.delegate = self
       
        
  
//        dateFormatter.dateFormat = "MM월 dd일 ▼"
//        let selectDateString = dateFormatter.string(from: Date())
//        selectDate.setTitle(selectDateString, for: .normal)
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
    
    func updateSelectDateButton(_ selectDateString: String) {
        selectDate.setTitle(selectDateString, for: .normal)
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "MM월 dd일 ▼"
        let selectDateString = dateFormatter.string(from: date)
        selectDate.setTitle(selectDateString, for: .normal)
    }
}
