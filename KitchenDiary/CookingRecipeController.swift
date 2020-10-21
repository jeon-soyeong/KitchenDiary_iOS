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
    var lastrecipeIdArr = [Int]()
    let ingredientQueue = DispatchQueue(label: "ingredient")
    var cooking: Cooking?
    
    struct CookingInfo: Codable {
        let Grid_20150827000000000226_1: CookingDetailInfo
    }

    struct CookingDetailInfo: Codable {
        let endRow: Int
        let totalCnt: Int
        let row: [RecipeInfo]
    }

    struct RecipeInfo: Codable {
        let RECIPE_ID: Int
        let RECIPE_NM_KO: String
        let IMG_URL: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lastrecipeIdArr: \(lastrecipeIdArr)")
        
        getCookingRecipe()
    }

    // MARK: - Table view data source

    func getCookingRecipe() {
        
        let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000226_1//1/1000"
        let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: encoded) else {return }
           
            URLSession.shared.dataTask(with: url) { [self] data, response, err in
                print("getRecipe 1")
                let task = DispatchWorkItem {
                    print("getRecipe 2")
                    guard let data = data else {return}
                    do {
                        print("getRecipe 3")
                        let decoder = JSONDecoder()
                        let cookingInfo = try? decoder.decode(CookingInfo.self, from: data)
                        print("cookingInfo: \(cookingInfo)")
                        guard let recipeCount = cookingInfo?.Grid_20150827000000000226_1.row.count else {return}
                        
                        
                        for i in 0 ..< lastrecipeIdArr.count {
                            for j in 0 ..< recipeCount {
                                guard let recipeId = cookingInfo?.Grid_20150827000000000226_1.row[j].RECIPE_ID else {return}
                                guard let recipeName = cookingInfo?.Grid_20150827000000000226_1.row[j].RECIPE_NM_KO else {return}
                                guard let imageUrl = cookingInfo?.Grid_20150827000000000226_1.row[j].IMG_URL else {return}
                                
                                
                                if lastrecipeIdArr[i] == recipeId {
                                     cooking = Cooking(recipeId: recipeId, recipeName: recipeName, imageUrl: imageUrl)
                                    print("cooking: \(cooking?.recipeId) \(cooking?.recipeName) \(cooking?.imageUrl)")
                                }
                            }
                        }
                    } catch let jsonArr {
                        print("Error \(jsonArr)")
                    }
                }
                self.ingredientQueue.sync(execute: task)
            }
            .resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

//        let cellIdentifier = "IngredientTableViewCell"
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? IngredientTableViewCell else {
//                fatalError ("The dequeued cell is not an instance of IngredientTableViewCell.")
//        }
//
//       let ingredient = ingredients[indexPath.row ]
//
//       cell.ingredientsName.text = ingredient.name
//       cell.storageMethod.text = ingredient.storageMethod
//       cell.expirationDate.text = ingredient.expirationDate
//       cell.ingredientsMemo.text = ingredient.memo

  

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
