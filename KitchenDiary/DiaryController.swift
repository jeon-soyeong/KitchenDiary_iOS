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
    var cookingDiaries = [CookingDiary]()
    var dataSentValue: String = ""
    let cookingEvaluationDataManager = CookingEvaluationDataManager.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.locale = Locale(identifier: "ko_KR")
       
    }
    override func viewWillAppear(_ animated: Bool) {
        cookingDiaries = cookingEvaluationDataManager.readCookingEvaluations()
        print("cookingDiaries: \(cookingDiaries)")
    }
}


extension DiaryController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookingDiaries.count
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cellIdentifier = "CookingDiaryTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let cookingDiaryCell = cell as? CookingDiaryTableViewCell else {
            return cell
        }
        cookingDiaryCell.cookingDiary = cookingDiaries[indexPath.row]
        return cell
    }
}
