//
//  BookMarkViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/27.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class BookMarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let myGroup = DispatchGroup()
    let sqlDataManager = SQLDataManager.init()
    let cookingRecipeController = CookingRecipeViewController.init()
    var cookings: [Cooking] = []
    var cookingDictionary: [Int : [String]] = [:]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        cookingDictionary = cookingRecipeController.getCookingCourse(cookings: cookings)
        switch(segue.identifier ?? "") {
            case "bookMarkCookingCourse":
                guard let cookingCourseViewController = segue.destination as? CookingCourseViewController else {
                    return
                }
                guard let selectedCookingCell = sender as? BookMarkTableViewCell else {
                    return
                }
                guard let indexPath = tableView.indexPath(for: selectedCookingCell) else {
                    return
                }
                guard let selectCookingDecriptionArray = cookingDictionary[indexPath.row] else {
                    return
                }
                cookingCourseViewController.cookingDescriptionArray = selectCookingDecriptionArray
                let cooking = cookings[indexPath.row]
                cookingCourseViewController.cooking = cooking
            default:
                break
        }
    }
}

// MARK: Life Cycle
extension BookMarkViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        cookings = sqlDataManager.readCookings()
    }
    override func viewWillAppear(_ animated: Bool) {
        cookings = sqlDataManager.readCookings()
        tableView.reloadData()
    }
}

extension BookMarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BookMarkTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let bookMarkCell = cell as? BookMarkTableViewCell else {
            return cell
        }
        bookMarkCell.cooking = cookings[indexPath.row]
        bookMarkCell.bookMarkButton.tag = indexPath.row
        bookMarkCell.bookMarkButton.addTarget(self, action: #selector(bookMarkbuttonPressed(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func bookMarkbuttonPressed(_ sender: UIButton) {
        let indexPath = sender.tag
        let cooking = cookings[indexPath]
        sqlDataManager.deleteByRecipeId(recipeId: cooking.recipeId)
        cookings.remove(at: indexPath)
        tableView.reloadData()
    }
}
