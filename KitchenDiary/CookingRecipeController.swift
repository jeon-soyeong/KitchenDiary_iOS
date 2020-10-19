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
    var compareArr = Set<Int>()
        
    struct  IngredientsInfo: Codable {
        let Grid_20150827000000000227_1: IngredientsDetailInfo
    }
    
    struct IngredientsDetailInfo: Codable {
        let endRow: Int
        let row: [RecipeInfo]
    }
    
    struct RecipeInfo: Codable  {
        let RECIPE_ID: Int
        let IRDNT_NM: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<ingredientsArr.count {
            print("111")
            let jsonString = "http://211.237.50.150:7080/openapi/c3f0717712af36dd95565986287a795a5b0a771beb317dfd99e462b743530477/json/Grid_20150827000000000227_1//1/1000?IRDNT_NM=\(ingredientsArr[i])"
            print("ingredientsArr[i]: \(ingredientsArr[i])")
            print("jsonString: \(jsonString)")
            print("222")

            let encoded: String = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            guard let url = URL(string: encoded) else { return print("안됨")}
            print("url: \(url)")
            print("333")
            
            URLSession.shared.dataTask(with: url) { (data, respnose, err) in
                print("444")
                guard let data = data else {return}
                print("555")
                do {
                    print("666")
                    let decoder = JSONDecoder()
                    let detailInfo = try? decoder.decode(IngredientsInfo.self, from: data)
                    let recipeCount = detailInfo?.Grid_20150827000000000227_1.row.count ?? 0
                    print("recipeCount: \(recipeCount)")
                    print("recipeRow: \(detailInfo?.Grid_20150827000000000227_1.row)")

                    var recipeIdArr = Set<Int>()
                    
                    for j in 0 ..< recipeCount {
                        let recipeId = detailInfo?.Grid_20150827000000000227_1.row[j].RECIPE_ID
                        let irdntName = detailInfo?.Grid_20150827000000000227_1.row[j].IRDNT_NM
                        recipeIdArr.insert(recipeId ?? -1)
                    }
                    self.compareArr = self.compareArr.intersection(recipeIdArr)
                } catch let jsonArr {
                    print("Error \(jsonArr)")
                }
            }.resume()
        }
        
        
  
        
    }

    // MARK: - Table view data source

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
