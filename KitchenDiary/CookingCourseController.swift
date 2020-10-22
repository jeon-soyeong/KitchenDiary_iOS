//
//  CookingCourseController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingCourseController: UITableViewController {

    var cooking: Cooking?
    var cookingDescriptionArr = [String]()
    let myGroup = DispatchGroup()
    let cookingCourseQueue = DispatchQueue(label: "cookingCourse")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       print("CookingCourseController, cooking: \(cooking)")
        print("cookingDescriptionArr: \(cookingDescriptionArr)")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.getCookingCourse()
      
        
    }

    func getCookingCourse() {
      print("aaa")
        let selectRecipeId = cooking?.recipeId
        let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000228_1//1/1000?RECIPE_ID=\(selectRecipeId!)"
            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: encoded) else {return }
        print("url: \(url)")
        print("bbb")
//                myGroup.enter()
                URLSession.shared.dataTask(with: url) { [self] data, response, err in
                    let task = DispatchWorkItem {
                        print("ccc")
                        guard let data = data else {return}
                        print("ddd")
                        do {
                            print("eee")
                            let decoder = JSONDecoder()
                            let cookingCourseInfo = try? decoder.decode(CookingCourseInfo.self, from: data)
                            guard let cookingCourseCount = cookingCourseInfo?.Grid_20150827000000000228_1.row.count else {return}
                            
                            for j in 0 ..< cookingCourseCount {
                                guard let cookingDescription = cookingCourseInfo?.Grid_20150827000000000228_1.row[j].COOKING_DC else {return}
                                cookingDescriptionArr.append(cookingDescription)
                                print("cookingDescriptionArr: \(cookingDescriptionArr)")
                              
                            }
                        } catch let jsonArr {
                            print("Error \(jsonArr)")
                        }
//                        myGroup.leave()
                    }
                    self.cookingCourseQueue.sync(execute: task)
                    self.tableView.reloadData()
                }
                .resume()
   
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cookingDescriptionArr.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cellIdentifier = "CookingCourseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CookingCourseTableViewCell else {
                fatalError ("The dequeued cell is not an instance of IngredientTableViewCell.")
        }
        
        cell.cookingDescription.text = cookingDescriptionArr[indexPath.row ]
        print("cell.cookingDescription.text: \(cell.cookingDescription.text)")

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
