//
//  CookingRecipeController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/18.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import sqlite3

struct CookingCourseInfo: Codable {
    let Grid_20150827000000000228_1: CookingCourseDetailInfo
}

struct CookingCourseDetailInfo: Codable {
    let row: [CourseInfo]
}

struct CourseInfo: Codable {
    let RECIPE_ID: Int
    let COOKING_DC: String
    let COOKING_NO: Int
}

class CookingRecipeController: UITableViewController {
    
    //받음
    var cookings = [Cooking]() 
    let cookingCourseQueue = DispatchQueue(label: "cookingCourse")
    var cookingDescriptionArr = [String]()
    var cookingDictionary = [Int : [String]]()
    let sqlDataManager = SQLDataManager.init()
    var loadCooking = [Cooking]()
    let myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCookingCourse(cookings: cookings)
        print("getCookingCourse.count: \(getCookingCourse(cookings: cookings).count)")
        print("getCookingCourse: \(getCookingCourse(cookings: cookings))")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCooking = sqlDataManager.readCookings()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        // #warning Incomplete implementation, return the number of rows
        return cookings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        
        let cellIdentifier = "CookingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let cookingCell = cell as? CookingTableViewCell else {
            return cell
        }
        cookingCell.cooking = cookings[indexPath.row]
        cookingCell.loadCooking = loadCooking
     
        cookingCell.bookMarkButton.tag = indexPath.row
        cookingCell.bookMarkButton.addTarget(self, action: #selector(bookMarkbuttonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func bookMarkbuttonPressed(_ sender: UIButton) {
         let indexPath = sender.tag

        let cooking = cookings[indexPath]
        if sender.isSelected == true {//delete
            sender.isSelected = false
            sqlDataManager.deleteByRecipeId(recipeId: cooking.recipeId)
            print("-------delete: \(cooking.recipeId)-------")
            
           
        }
        else {// insert
            sender.isSelected = true
            sqlDataManager.insertCookings(cooking.recipeId, cooking.recipeName, cooking.imageUrl)
            print("-------insert: \(cooking.recipeId), \(cooking.recipeName), \(cooking.imageUrl)-------")
        }
    }
    
    func getCookingCourse(cookings: [Cooking]) -> [Int : [String]] {
        for i in 0 ..< cookings.count {
            let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000228_1//1/1000?RECIPE_ID=\(cookings[i].recipeId)"
            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: encoded) else {
                fatalError("no url")
            }
            print("url: \(url)")
            myGroup.enter()
                URLSession.shared.dataTask(with: url) { [self] data, response, err in
                    let task = DispatchWorkItem {
                        guard let data = data else {return}
                        do {
                            let decoder = JSONDecoder()
                            let cookingCourseInfo = try? decoder.decode(CookingCourseInfo.self, from: data)
                            guard let cookingCourseCount = cookingCourseInfo?.Grid_20150827000000000228_1.row.count else {return}
                            
                            cookingDescriptionArr = []
                            for j in 0 ..< cookingCourseCount {
                                guard let cookingDescription = cookingCourseInfo?.Grid_20150827000000000228_1.row[j].COOKING_DC else {return}
                               
                                cookingDescriptionArr.append(cookingDescription)
                            }
                            cookingDictionary.updateValue(cookingDescriptionArr, forKey: i)
                        } catch let jsonArr {
                        }
                        myGroup.leave()
                    }
                    self.cookingCourseQueue.sync(execute: task)
                }
                .resume()
        }
        myGroup.wait(timeout: .distantFuture)
        return cookingDictionary
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            case "CookingCourse":
                guard let cookingCourseController = segue.destination as? CookingCourseController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let selectedCookingCell = sender as? CookingTableViewCell else {
                    fatalError("Unexpected sender: \(sender)")
                }
                
                guard let indexPath = tableView.indexPath(for: selectedCookingCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
    
                guard let selectCookingDecriptionArray = cookingDictionary[indexPath.row] else {
                    return
                }
                cookingCourseController.cookingDescriptionArray = selectCookingDecriptionArray
                
                let cooking = cookings[indexPath.row]
                cookingCourseController.cooking = cooking
                
            case "goToDetailDiary":
                guard let diaryDetailController = segue.destination as? DiaryDetailController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let goDiaryButton = sender as? UIButton else {
                    fatalError("Unexpected sender: \(sender)")
                }
                
                let buttonPosition: CGPoint = goDiaryButton.convert(CGPoint.zero, to: self.tableView)

                guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition)?.row else {
                    fatalError("Unexpected indexPath")
                }

                let cookingName = cookings[indexPath].recipeName
                print("cookings[indexPath.row].recipeName: \(cookings[indexPath].recipeName)")
                diaryDetailController.recipeName = cookingName
        default: break
        }
    }

}
