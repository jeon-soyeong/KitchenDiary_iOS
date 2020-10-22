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
    var cookings = [Cooking]()
   
    // tabBar 이동
    @IBAction func goToKitchenDiary(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cookings.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "CookingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CookingTableViewCell else {
            fatalError ("The dequeued cell is not an instance of CookingTableViewCell.")
        }

       let cooking = cookings[indexPath.row ]
        
        cell.cookingName.text = cooking.recipeName
        guard let url = URL(string: cooking.imageUrl) else {
            fatalError ("no url")
        }
        if let data = try? Data(contentsOf: url) {
            cell.cookingImage.image = UIImage(data: data)
        }
        
        return cell
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
                
                let selectedCooking = cookings[indexPath.row]
                cookingCourseController.cooking = selectedCooking
                
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}
