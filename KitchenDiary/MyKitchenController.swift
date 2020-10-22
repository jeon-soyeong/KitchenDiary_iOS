//
//  MyKitchenController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/18.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import os.log

class MyKitchenController: UITableViewController {

    @IBOutlet weak var cookingButton: UIButton!
    
    var ingredients = [Ingredients]()
    var ingredientsArr = [String]()

    var recipeIdArr = [Int]()
    var overlapValueArr = [Int]()
    var overlapValueSet = Set<Int>()
    let ingredientQueue = DispatchQueue(label: "ingredient")
    var lastrecipeIdArr = [Int]()
    let myGroup = DispatchGroup()
    var essentialIrdntArr = [String]()
    
    var cookings: [Cooking] = []

    struct IngredientsInfo: Codable {
        let Grid_20150827000000000227_1: IngredientsDetailInfo
    }

    struct IngredientsDetailInfo: Codable {
        let row: [RecipeInfo]
    }

    struct RecipeInfo: Codable {
        let RECIPE_ID: Int
        let IRDNT_NM: String
    }

    struct CookingInfo: Codable {
        let Grid_20150827000000000226_1: CookingDetailInfo
    }

    struct CookingDetailInfo: Codable {
        let row: [CookingRecipeInfo]
    }

    struct CookingRecipeInfo: Codable {
        let RECIPE_ID: Int
        let RECIPE_NM_KO: String
        let IMG_URL: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cookingButton.layer.cornerRadius = 0.3 * cookingButton.bounds.size.height
        
       // tableViewCell Height AutoSizing
        tableView.rowHeight = UITableView.automaticDimension
        
        if let savedIngredients = loadIngredients() {
            ingredients += savedIngredients
        }
        
        //CookingController로 보낼 재료 배열
        for i in 0..<ingredients.count {
            ingredientsArr.append(ingredients[i].name)
            print(" ingredientsArr: \(ingredientsArr[i])")
        }

        self.getRecipeIdFromIngredients()
    }

    //섹션표시 - Table view 1개만 필요
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //행 수 반환
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }

    //셀 구성 & 표시
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "IngredientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? IngredientTableViewCell else {
                fatalError ("The dequeued cell is not an instance of IngredientTableViewCell.")
        }

       let ingredient = ingredients[indexPath.row ]

       cell.ingredientsName.text = ingredient.name
       cell.storageMethod.text = ingredient.storageMethod
       cell.expirationDate.text = ingredient.expirationDate
       cell.ingredientsMemo.text = ingredient.memo
        
        print("cell.ingredientsName.text : \(cell.ingredientsName.text)")
        print("ingredient.name : \(ingredient.name)")
        
        cell.warning.isHidden = true
    
        //날짜 차이 구하기
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let now = NSDate()
       
        let exprireDate: Date = dateFormatter.date(from:ingredient.expirationDate) ?? now as Date
        let nowDate = now as Date
        
        let interval = exprireDate.timeIntervalSince(nowDate)
        let days = Int(interval / 86400)
        
        //2일전 부터 보이기
        if days <= 1 {
            cell.warning.isHidden = false
        }
        
        //label 줄바꿈
        cell.ingredientsMemo.preferredMaxLayoutWidth = (tableView.bounds.width - 120)
        cell.ingredientsMemo.numberOfLines = 0
    
       return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            ingredients.remove(at: indexPath.row)
            saveIngredients()
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
  
    
    /*
     Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
     Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    //전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {

        case "AddItem":
            os_log("Adding a new ingredient.", log: OSLog.default, type: .debug)

        case "Cooking":
            guard let cookingRecipeController = segue.destination as? CookingRecipeController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            cookingRecipeController.cookings = cookings
            
        case "ShowDetail":
            guard let fillInIngredientsController = segue.destination as? FillInIngredientsController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedIngredientsCell = sender as? IngredientTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }

            guard let indexPath = tableView.indexPath(for: selectedIngredientsCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedIngredients = ingredients[indexPath.row]
            fillInIngredientsController.ingredient = selectedIngredients
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    //MARK: Actions
    @IBAction func unwindToIngredientslList (sender: UIStoryboardSegue) {
        print("unwindToIngredientslList 호출 1")
        if let sourceViewController = sender.source as? FillInIngredientsController, let ingredient = sourceViewController.ingredient {

            //행이 선택(편집)되었는지 여부 확인
           if let selectedIndexPath = tableView.indexPathForSelectedRow {
               // Update an existing meal.
               ingredients[selectedIndexPath.row] = ingredient
               tableView.reloadRows(at: [selectedIndexPath], with: .none)
           }
           else {
               // Add a new ingredient.
               let newIndexPath = IndexPath(row: ingredients.count, section: 0)

               ingredients.append(ingredient)
               tableView.insertRows(at: [newIndexPath], with: .automatic)
           }
            //Save the meals.
            saveIngredients()
        }
    }
    
    
    
    private func saveIngredients() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(ingredients, toFile: Ingredients.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Ingredients successfully saved.", log: OSLog.default, type: .debug)
        } else {
                 os_log("failed to save Ingredients", log: OSLog.default, type: .error)
        }
    }

    private func loadIngredients() -> [Ingredients]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Ingredients.ArchiveURL.path) as? [Ingredients]
    }

    func getRecipeIdFromIngredients() {
        
            for i in 0..<self.ingredientsArr.count {
                let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000227_1//1/1000?IRDNT_NM=\(self.ingredientsArr[i])"
                let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                guard let url = URL(string: encoded) else {return }
                        
                    myGroup.enter()
                    URLSession.shared.dataTask(with: url) { [self] data, response, err in
                        let task = DispatchWorkItem {
                            guard let data = data else {return}
                            do {
                                let decoder = JSONDecoder()
                                let recipeInfo = try? decoder.decode(IngredientsInfo.self, from: data)
                                guard let recipeCount = recipeInfo?.Grid_20150827000000000227_1.row.count else {return}
                                
                                for j in 0 ..< recipeCount {
                                    let recipeId = recipeInfo?.Grid_20150827000000000227_1.row[j].RECIPE_ID
                                    let irdntName = recipeInfo?.Grid_20150827000000000227_1.row[j].IRDNT_NM
                                    self.recipeIdArr.append(recipeId ?? -1)
                                }
                                for a in 0 ..< self.recipeIdArr.count-1 {
                                    for b in a+1 ..< self.recipeIdArr.count {
                                        if self.recipeIdArr[a] == recipeIdArr[b] {
                                            self.overlapValueArr.append(recipeIdArr[a])
                                        }
                                    }
                                }
                                overlapValueSet = (Set(overlapValueArr))
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
            
            myGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, err in
                let task = DispatchWorkItem {
                    guard let data = data else {return}
                    do {
                        let decoder = JSONDecoder()
                        let recipeInfo = try? decoder.decode(IngredientsInfo.self, from: data)
                        guard let recipeCount = recipeInfo?.Grid_20150827000000000227_1.row.count else {return}
                        self.essentialIrdntArr = []
                        
                        for n in 0 ..< recipeCount {
                            let irdntName = recipeInfo?.Grid_20150827000000000227_1.row[n].IRDNT_NM
                            let recipeIdNum = recipeInfo?.Grid_20150827000000000227_1.row[n].RECIPE_ID
                            self.essentialIrdntArr.append(irdntName ?? "")
            
                            var cnt = 0
                            if n == recipeCount-1 {
                                for m in 0 ..< self.essentialIrdntArr.count {
                                    if self.ingredientsArr.contains(self.essentialIrdntArr[m]) == true {
                                        cnt += 1
                                    }
                                }
                                if cnt == recipeCount {
                                    self.lastrecipeIdArr.append(recipeIdNum ?? 0)
                                }
                            }
                        }
                    } catch {
                    }
                    self.myGroup.leave()
                }
                self.ingredientQueue.sync(execute: task)
            }.resume()
        }
        
        myGroup.wait(timeout: .distantFuture)
        
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
                                    guard let cooking = Cooking(recipeId: recipeId, recipeName: recipeName, imageUrl: imageUrl) else {
                                        return
                                    }
                                    
                                    print("cooking: \(cooking.recipeId) \(cooking.recipeName) \(cooking.imageUrl)")
                                    cookings.append(cooking)
                                    print("cookingsArr:\(cookings) ")
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
    
}
