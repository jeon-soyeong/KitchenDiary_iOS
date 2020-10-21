//
//  CookingRecipeController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/18.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingRecipeController: UITableViewController {

    //받음
    var ingredientsArr = [String]()
    var recipeIdArr = [Int]()
    var overlapValueArr = [Int]()
    var overlapValueSet = Set<Int>()
    let ingredientQueue = DispatchQueue(label: "ingredient")
    var LastrecipeIdArr = [Int]()
    let myGroup = DispatchGroup()
    var essentialIrdntArr = [String]()
    
    struct IngredientsInfo: Codable {
        let Grid_20150827000000000227_1: IngredientsDetailInfo
    }
    
    struct IngredientsDetailInfo: Codable {
        let endRow: Int
        let totalCnt: Int
        let row: [RecipeInfo]
    }
    
    struct RecipeInfo: Codable {
        let RECIPE_ID: Int
        let IRDNT_NM: String
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getRecipeIdFromIngredients()
    }

    // MARK: - Table view data source

    func getRecipeIdFromIngredients() {
        
            for i in 0..<self.ingredientsArr.count {
                print("getRecipe 00")
                
            let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000227_1//1/1000?IRDNT_NM=\(self.ingredientsArr[i])"
            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: encoded) else {return }
                print("getRecipe 0")
                         
                myGroup.enter()
                URLSession.shared.dataTask(with: url) { [self] data, response, err in
                    print("getRecipe 1")
                    let task = DispatchWorkItem {
                        print("getRecipe 2")
                        guard let data = data else {return}
                        do {
                            print("getRecipe 3")
                            let decoder = JSONDecoder()
                            let recipeInfo = try? decoder.decode(IngredientsInfo.self, from: data)
                            print("recipeInfo: \(recipeInfo)")
                            guard let recipeCount = recipeInfo?.Grid_20150827000000000227_1.row.count else {return}
                            
                            for j in 0 ..< recipeCount {
                                let recipeId = recipeInfo?.Grid_20150827000000000227_1.row[j].RECIPE_ID
                                let irdntName = recipeInfo?.Grid_20150827000000000227_1.row[j].IRDNT_NM
                                self.recipeIdArr.append(recipeId ?? -1)
                                
                                print("recipeId: \(recipeId), irdntName: \(irdntName)")
                                print("recipeIdArr: \(recipeIdArr)")
                            }
                            for a in 0 ..< self.recipeIdArr.count-1 {
                                for b in a+1 ..< self.recipeIdArr.count {
                                    if self.recipeIdArr[a] == recipeIdArr[b] {
                                        self.overlapValueArr.append(recipeIdArr[a])
                                    }
                                }
                            }
                            overlapValueSet = (Set(overlapValueArr))
                            
                           print("compareSet: \(overlapValueSet)")
                           print(" compareSet.count : \(overlapValueSet.count)")
                        } catch let jsonArr {
                            print("Error \(jsonArr)")
                        }
                        myGroup.leave()
                    }
                    self.ingredientQueue.sync(execute: task)
                }
                .resume()
       }
        
        myGroup.wait(timeout: .distantFuture)

        for r in 0 ..< self.overlapValueSet.count {
            
            let overlapValueSetToArr = (Array(overlapValueSet))
            let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000227_1//1/1000?RECIPE_ID=\(overlapValueSetToArr[r])"
            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            guard let url = URL(string: encoded) else {return}
            print("url: \(url)")
            
            URLSession.shared.dataTask(with: url) { data, response, err in
                let task = DispatchWorkItem {
                    guard let data = data else {return}
                    do {
                        let decoder = JSONDecoder()
                        let recipeInfo = try? decoder.decode(IngredientsInfo.self, from: data)
                        guard let recipeCount = recipeInfo?.Grid_20150827000000000227_1.row.count else {return}
                        print("compareArrs[r]: \(overlapValueSetToArr[r])")
                        print("recipeCount: \(recipeCount)")
                        self.essentialIrdntArr = []
                        
                        for n in 0 ..< recipeCount {
                            let irdntName = recipeInfo?.Grid_20150827000000000227_1.row[n].IRDNT_NM
                            let recipeIdNum = recipeInfo?.Grid_20150827000000000227_1.row[n].RECIPE_ID
                            self.essentialIrdntArr.append(irdntName ?? "")
            
                            var cnt = 0
                            if n == recipeCount-1 {
                                for m in 0 ..< self.essentialIrdntArr.count {
                                    if self.ingredientsArr.contains(self.essentialIrdntArr[m]) == true {
                                        print("self.ingredientsArr: \(self.ingredientsArr)")
                                        print("self.irdntArr: \(self.essentialIrdntArr)")
                                        cnt += 1
                                        print("cnt: \(cnt)")
                                    }
                                }
                                if cnt == recipeCount {
                                    self.LastrecipeIdArr.append(recipeIdNum ?? 0)
                                    print("LastrecipeIdArr: \(self.LastrecipeIdArr)")
                                }
                            }
                        }
                    } catch {
                    }
                }
                self.ingredientQueue.sync(execute: task)
            }.resume()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
