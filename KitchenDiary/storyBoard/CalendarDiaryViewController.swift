//
//  CalendarDiaryViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/10.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarDiaryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var cookingDiaries = [CookingDiary]()
    var headerView = CollectionReusableView()
    
    override func viewDidLoad() {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations()
        collectionView.reloadData()
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDiaryDetail" {
            guard let diaryDetailController = segue.destination as? DiaryDetailController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            if let indexPath = sender as? Int {
                let cookingDiary = cookingDiaries[indexPath]
                print("CalendarDiaryViewController.cookingIndex : \(cookingDiary.cookingIndex)")
                diaryDetailController.saveButtonMode = "edit"
                diaryDetailController.viewModel.update(model: cookingDiary)
            }
        }
    }
}

extension CalendarDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         switch kind {
         case UICollectionView.elementKindSectionHeader:
          
           guard
            let headerView = collectionView.dequeueReusableSupplementaryView(
               ofKind: kind,
               withReuseIdentifier: "CollectionHeader",
               for: indexPath) as? CollectionReusableView
             else {
               fatalError("Invalid view type")
           }
            headerView.updateUI()
           return headerView
         default:
           assert(false, "Invalid element type")
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cookingDiaries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDiaryDetail", sender: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CookingDiaryCell", for: indexPath) as? CookingDiaryCell else {
            return UICollectionViewCell()
        }
        
        let cookingDiary = cookingDiaries[indexPath.row]
        cell.updateUI(cookingDiary)
        cell.deleteButton.tag = indexPath.row // 버튼에 tag를 입력해줍니다!!
        cell.deleteButton.addTarget(self, action: #selector(deletingCell(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    
    @objc func deletingCell(sender : UIButton) {
        let cookingDiary = cookingDiaries[sender.tag]
        collectionView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
        CookingEvaluationDataManager.shared.deleteByCookingIndex(cookingIndex: cookingDiary.cookingIndex)
        cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations()
        collectionView.reloadData()
    }
}
