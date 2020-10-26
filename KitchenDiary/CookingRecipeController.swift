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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad!!")
        
        getCookingCourse()
        
        sqlDataManager.openDatabase()
    }
    
    // tabBar 이동
    @IBAction func goToKitchenDiary(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
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
        let cookingCell =  cell as? CookingTableViewCell
        
        let cooking = cookings[indexPath.row]
        cookingCell?.cookingName.text = cooking.recipeName
        
        let bookMarkCookings = sqlDataManager.readCookings()
        cookingCell?.bookMarkButton.isSelected = bookMarkCookings.contains(where: { (bookMarkCooking) -> Bool in
            return cooking.recipeId == bookMarkCooking.recipeId
        })
        
        guard let url = URL(string: cooking.imageUrl) else {
            return cell
        }
        if let data = try? Data(contentsOf: url) {
            cookingCell?.cookingImage.image = UIImage(data: data)
        }
        cookingCell?.bookMarkButton.tag = indexPath.row
        cookingCell?.bookMarkButton.addTarget(self, action: #selector(bookMarkbuttonPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func bookMarkbuttonPressed(_ sender: AnyObject) {
        let button = sender as? UIButton
        guard let cell = button?.superview?.superview as? UITableViewCell else {
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        print(indexPath.row)
        
        let cooking = cookings[indexPath.row]
        if button?.isSelected == true {//delete
            button?.isSelected = false
            sqlDataManager.deleteByRecipeId(recipeId: cooking.recipeId)
        }
        else {// insert
            button?.isSelected = true
            print("cooking.recipeId:\(cooking.recipeId),\(cooking.recipeName), \(cooking.imageUrl) ")
            sqlDataManager.insertCookings(cooking.recipeId, cooking.recipeName, cooking.imageUrl)
        }
        
        let bookMarkCookings = sqlDataManager.readCookings()
        for i in 0 ..< bookMarkCookings.count {
            print("bookMarkCookings[i].recipeId: \(bookMarkCookings[i].recipeId)")
            print("bookMarkCookings[i].recipeName: \(bookMarkCookings[i].recipeName)")
            print("bookMarkCookings[i].imageUrl: \(bookMarkCookings[i].imageUrl)")
        }
        
    }
    
    func getCookingCourse() {
    
        for i in 0 ..< cookings.count {
   
            let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000228_1//1/1000?RECIPE_ID=\(cookings[i].recipeId)"
            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: encoded) else {return }
           
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
                    }
                    self.cookingCourseQueue.sync(execute: task)
                }
                .resume()
        }
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
                break
                
            default:
                fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}
