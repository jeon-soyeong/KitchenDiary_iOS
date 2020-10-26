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
    let sqlDataManager = SQLDataManager.init()
    var cookings = [Cooking]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cookings = sqlDataManager.readCookings()
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
        bookMarkCell.bookMarkButton.addTarget(self, action: #selector(bookMarkbuttonPressed(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func bookMarkbuttonPressed(_ sender: UIButton) {
         let indexPath = sender.tag

        let cooking = cookings[indexPath]
        sqlDataManager.deleteByRecipeId(recipeId: cooking.recipeId)
       // tableView.reloadData()
    }
}


extension BookMarkViewController: UITableViewDelegate {
    
}

