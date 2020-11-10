//
//  DiaryController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import FSCalendar

class DiaryController: UIViewController {
    @IBOutlet weak var selectDate: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    var cookingDiaries = [CookingDiary]()
    var dataSentValue: String = ""
    let dateFormatter = DateFormatter()
    let cookingTableCell = CookingTableViewCell.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        tableView.delegate = self
        cookingTableCell.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(cookingTableCell)
        
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
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
    override func viewWillAppear(_ animated: Bool) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
        //            guard let self = self else {
        //                return
        //            }
        //        }
        cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        
        case "showDiary":
            guard let diaryDetailController = segue.destination as? DiaryDetailController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedDiariesCell = sender as? CookingDiaryTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedDiariesCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let cookingDiary = cookingDiaries[indexPath.row]
            diaryDetailController.cookingDiary = cookingDiary
            diaryDetailController.saveButtonMode = "edit"
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}

extension DiaryController: FSCalendarDelegate, FSCalendarDataSource {
    
    //    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    //          tableViewTopConstraint.constant = bounds.height
    //          self.view.layoutIfNeeded()
    //    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    @IBAction func calendarToggle(_ sender: Any) {
        self.view.bringSubviewToFront(tableView)
        
        if self.calendar.scope == FSCalendarScope.month {
            self.calendar.scope = .week
            
            cookingTableCell.topAnchor.constraint(equalTo: calendar.contentView.bottomAnchor, constant: 0).isActive = true
            
            tableView.contentInset.top = 250
            
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.scope = .month
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일 ▼"
        let selectDateString = dateFormatter.string(from: date)
        selectDate.setTitle(selectDateString, for: .normal)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cookingDiary = cookingDiaries[indexPath.row]
            CookingEvaluationDataManager.shared.deleteByCookingIndex(cookingIndex: cookingDiary.cookingIndex)
            cookingDiaries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
