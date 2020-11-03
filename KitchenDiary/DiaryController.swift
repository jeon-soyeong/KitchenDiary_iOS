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
    
    @IBOutlet weak var tableView: UITableView!
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
        tableView.reloadData()
    }
    
    //전달
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
    
    //MARK: Actions
//    @IBAction func unwindToIngredientslList (sender: UIStoryboardSegue) {
//        print("unwindToIngredientslList 호출 1")
//        if let sourceViewController = sender.source as? DiaryDetailController, let cookingDiary = sourceViewController.cookingDiary {
//            if let selectedIndexPath = tableView.indexPathForSelectedRow {
//               cookingDiaries[selectedIndexPath.row] = cookingDiary
//               // tableView.reloadRows(at: [selectedIndexPath], with: .none)
//
//                let cookingName = cookingDiaries[selectedIndexPath.row].cookingName
//                guard let cookingPhoto = cookingDiaries[selectedIndexPath.row].cookingPhoto else {
//                    fatalError("no cookingPhoto")
//                }
//                let cookingRating = cookingDiaries[selectedIndexPath.row].cookingRating
//                let cookingMemo = cookingDiaries[selectedIndexPath.row].cookingMemo
//                let cookingIndex = cookingDiaries[selectedIndexPath.row].cookingIndex
//                print("전달할 데이터 : \(cookingName), \(cookingPhoto), \(cookingRating), \(cookingMemo), \(cookingIndex)")
//                //dataManager update
//                cookingEvaluationDataManager.updateCookingEvaluations(cookingName, cookingPhoto, cookingRating, cookingMemo, cookingIndex)
//                cookingEvaluationDataManager.readCookingEvaluations()
//                tableView.reloadData()
//            }
//        }
//    }
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
            print("delete cookingIndex: \(cookingDiary.cookingIndex)")
            print("delete cookingName: \(cookingDiary.cookingName)")
           
            cookingEvaluationDataManager.deleteByCookingIndex(cookingIndex: cookingDiary.cookingIndex)
            cookingDiaries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
