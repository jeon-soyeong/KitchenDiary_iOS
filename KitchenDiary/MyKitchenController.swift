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
            cookingRecipeController.ingredientsArr = ingredientsArr
            
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

}
