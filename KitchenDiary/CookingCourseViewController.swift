//
//  CookingCourseViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/22.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//
import UIKit

class CookingCourseViewController: UITableViewController {
    @IBOutlet weak var cookingName: UILabel!
    @IBOutlet weak var cookingImage: UIImageView!
    var cooking: Cooking?
    var cookingDescriptionArray: [String] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cookingName.text = cooking?.recipeName
        guard let cookingImageUrl = cooking?.imageUrl else {
            return
        }
        guard let url = URL(string: cookingImageUrl) else {
            fatalError ("no url")
        }
        if let data = try? Data(contentsOf: url) {
            cookingImage.image = UIImage(data: data)
        }
        //tableViewCell Height AutoSizing
        tableView.rowHeight = UITableView.automaticDimension
        
        let backwardImage = UIImage(systemName: "chevron.backward")
        let backbutton = UIBarButtonItem(image: backwardImage, style: .done, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backbutton
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }
    
    @objc func back() {
          self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        super.numberOfSections(in: tableView)
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        return cookingDescriptionArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        let cellIdentifier = "CookingCourseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CookingCourseTableViewCell else {
            fatalError ("The dequeued cell is not an instance of IngredientTableViewCell.")
        }
        cell.cookingDescription.text = cookingDescriptionArray[indexPath.row ]
        //label 줄바꿈
        cell.cookingDescription.preferredMaxLayoutWidth = (tableView.bounds.width - 70)
        cell.cookingDescription.numberOfLines = 0
        return cell
    }
}
