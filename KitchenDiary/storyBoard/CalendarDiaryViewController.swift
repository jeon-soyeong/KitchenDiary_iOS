//
//  CalendarDiaryViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/10.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarDiaryViewModel {
    var cookingDiaries = [CookingDiary]()
    var numOfCookingDiaries: Int {
        return cookingDiaries.count
    }
    func cookingDiaries(at index: Int) -> CookingDiary {
        return cookingDiaries[index]
    }
}

class CalendarDiaryViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var selectDate: UIButton!
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var todayButton: UIButton!
    let viewModel = CalendarDiaryViewModel()
    let dateFormatter = DateFormatter()
    var headerFixPart: Int = 0
    var headerViewHeight = 410 {
        didSet {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    var eventDates = [String]()
    var eventCount: Int = 0
    static var eventDatesDictionary = [String : Int]()
    var retunCount: String = ""
    let userDefaults = UserDefaults.standard
    
    @IBAction func goToTodayDate(_ sender: Any) {
        calendar.setCurrentPage(Date(), animated: true)
        calendar.select(Date(), scrollToDate: true)
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 ▼"
        let todayDate = dateFormatter.string(from: Date())
        selectDate.setTitle(todayDate, for: .normal)
        
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        let todayDateString = dateFormatter.string(from: Date())
        viewModel.cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations(todayDateString)
        collectionView.reloadData()
    }
    
    @IBAction func dateToggle(_ sender: Any) {
        headerFixPart = Int(selectDate.bounds.maxY) + Int(calendarImage.bounds.maxY)
        var calendarHeight = Int(calendar.contentView.bounds.maxY)
        headerViewHeight = calendarHeight + headerFixPart
        if calendar.scope == FSCalendarScope.month {
            calendar.scope = .week
        } else {
            calendar.scope = .month
            calendar.setScope(.month, animated: true)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        todayButton.layer.cornerRadius = 0.3 * todayButton.bounds.size.height
        scrollView.addGestureRecognizer(collectionView.panGestureRecognizer)
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "M월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont(name: "KoreanPGSB", size: 23)!
        calendar.appearance.weekdayTextColor = UIColor.black
        calendar.appearance.selectionColor = UIColor.black
        calendar.locale = Locale(identifier: "ko_KR")
        
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 ▼"
        let selectDateString = dateFormatter.string(from: Date())
        selectDate.setTitle(selectDateString, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventDates = CookingEvaluationDataManager.shared.selectEventDate()
        print("CalendarDiaryViewController.eventDatesDictionary : \(CalendarDiaryViewController.eventDatesDictionary)")
        calendar(calendar, numberOfEventsFor: Date())
        calendar.reloadData()
        print("eventDates: \(eventDates)")
        scrollView.addGestureRecognizer(collectionView.panGestureRecognizer)
        collectionViewReloadData()
    }
   
    func collectionViewReloadData() {
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        guard let selectDateTitle = selectDate.titleLabel?.text else {
            return
        }
        let selectDateTitleSubString =  selectDateTitle.dropLast(2)
        viewModel.cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations(String(selectDateTitleSubString))
        collectionView.reloadData()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDiaryDetail" {
            guard let diaryDetailController = segue.destination as? DiaryDetailController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            if let indexPath = sender as? Int {
                let cookingDiary = viewModel.cookingDiaries(at: indexPath)
                print("CalendarDiaryViewController.cookingIndex : \(cookingDiary.cookingIndex)")
                diaryDetailController.saveButtonMode = "edit"
                diaryDetailController.viewModel.update(model: cookingDiary)
            }
        }
    }
}

extension CalendarDiaryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numOfCookingDiaries
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDiaryDetail", sender: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CookingDiaryCell", for: indexPath)
        let cookingDiaryCell = cell as? CookingDiaryCell

        let cookingDiary = viewModel.cookingDiaries(at: indexPath.item)
        cookingDiaryCell?.updateUI(cookingDiary)
        cookingDiaryCell?.deleteButton.tag = indexPath.item
        cookingDiaryCell?.deleteButton.addTarget(self, action: #selector(deletingCell(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if calendar.contentView.bounds.maxY < 320 {
            return UIEdgeInsets(top: calendar.contentView.bounds.maxY + CGFloat(headerFixPart + 20), left: 0, bottom: 0, right: 0)
            
        } else {
            return UIEdgeInsets(top: 440, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func deletingCell(sender : UIButton) {
        let cookingDiary = viewModel.cookingDiaries(at: sender.tag)
       print("cookingDiary.cookingIndex : \(cookingDiary.cookingIndex)")
        collectionView.deleteItems(at: [IndexPath.init(item: sender.tag, section: 0)])
        CookingEvaluationDataManager.shared.deleteByCookingIndex(cookingIndex: cookingDiary.cookingIndex)
        collectionViewReloadData()
        
        guard let selectDateTitle = selectDate.titleLabel?.text else {
            return
        }
        let selectDateTitleSubString =  selectDateTitle.dropLast(2)
        guard let eventDownCount = CalendarDiaryViewController.eventDatesDictionary[String(selectDateTitleSubString)] else {
            return
        }
        
        if let eventDictionary = UserDefaults.standard.object(forKey: "eventDictionary") as? Data {
            guard let eventDatesDictionary = NSKeyedUnarchiver.unarchiveObject(with: eventDictionary) as? [String : Int] else {
                return
            }
            print("eventDatesDictionary: \(eventDatesDictionary)")
            CalendarDiaryViewController.eventDatesDictionary = eventDatesDictionary
        }
        
        print("CalendarDiaryViewController.eventDatesDictionary : \(CalendarDiaryViewController.eventDatesDictionary)")
        CalendarDiaryViewController.eventDatesDictionary.updateValue(eventDownCount-1, forKey: String(selectDateTitleSubString))
        print("CalendarDiaryViewController.eventDatesDictionary : \(CalendarDiaryViewController.eventDatesDictionary)")
        
        let eventDictionary = try? NSKeyedArchiver.archivedData(withRootObject: CalendarDiaryViewController.eventDatesDictionary, requiringSecureCoding: false)
        UserDefaults.standard.set(eventDictionary, forKey: "eventDictionary")
        
        calendar(calendar, numberOfEventsFor: Date())
        calendar.reloadData()
    }
    
}

extension CalendarDiaryViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
 
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "YYYY년 MM월 dd일 ▼"
        let selectDateStringForButton = dateFormatter.string(from: date)
        selectDate.setTitle(selectDateStringForButton, for: .normal)
        
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        let selectDateString = dateFormatter.string(from: date)
        viewModel.cookingDiaries = CookingEvaluationDataManager.shared.readCookingEvaluations(selectDateString)
        collectionView.reloadData()
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        let dateString = dateFormatter.string(from: date)
        
        if CalendarDiaryViewController.eventDatesDictionary[dateString] == nil {
            eventCount = 0
            for i in 0..<eventDates.count {
                if eventDates[i].contains(dateString) {
                    eventCount += 1
                    CalendarDiaryViewController.eventDatesDictionary.updateValue(eventCount, forKey: eventDates[i])
                    let eventDictionary = try? NSKeyedArchiver.archivedData(withRootObject: CalendarDiaryViewController.eventDatesDictionary, requiringSecureCoding: false)
                    UserDefaults.standard.set(eventDictionary, forKey: "eventDictionary")
                }
            }
        } else {
            guard let changeCount = CalendarDiaryViewController.eventDatesDictionary[dateString] else {
                return -1
            }
            print("changeCount: \(changeCount)")
            eventCount = changeCount
        }
        return eventCount
    }
}

extension CalendarDiaryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffSetY = scrollView.contentOffset.y
        headerView.transform = CGAffineTransform(translationX: 0, y: -contentOffSetY)
    }
}
