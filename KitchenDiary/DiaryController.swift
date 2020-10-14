//
//  DiaryController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import FSCalendar

class DiaryController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.locale = Locale(identifier: "ko_KR")

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Actions
    @IBAction func unwindToDiaryList (sender: UIStoryboardSegue) {
        print("unwindToMealList 호출 1")
        if let sourceViewController = sender.source as? DiaryDetailController {
            print("unwindToMealList 호출 2")
        }
    }
    
    
}
