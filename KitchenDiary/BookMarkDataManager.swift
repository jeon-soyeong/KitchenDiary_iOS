//
//  BookMarkDataManager.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation

struct RecipeColumns {
    var columnType: ColumnType
    static let columnArray = [ColumnArray(value: ColumnInfo(name: "recipeId", type: ColumnType.integer.rawValue, primaryKey: true)),
                              ColumnArray(value: ColumnInfo(name: "recipeName", type: ColumnType.text.rawValue, primaryKey: false)),
                              ColumnArray(value: ColumnInfo(name: "imageUrl", type: ColumnType.text.rawValue, primaryKey: false))]
}

public class BookMarkDataManager {
    
    var bookMarkDataManager: SQLDataManager
    init() {
        bookMarkDataManager = SQLDataManager.init(SQLDataInfo(dbPath: "CookingBookMark.sqlite", tableName: "CookingBookMark", column: RecipeColumns.columnArray))
    }
    func insertBookMark(_ paramValue: [SQLValue]) {
        bookMarkDataManager.insert(paramValue)
    }
    
    func selectBookMark(_ paramValue: [SQLValue], _ whereValue: [SQLValue]) -> [Cooking] {
        let bookMarkArray = bookMarkDataManager.select(paramValue, whereValue)
        var recipeId: Int = 0
        var recipeName: String = ""
        var imageUrl: String = ""
        var cookingArray: [Cooking] = []
       
        print("bookMarkArray: \(bookMarkArray)")
        for i in 0..<bookMarkArray.count {
            print("bookMarkArray[i]: \(bookMarkArray[i])")
            for (values) in bookMarkArray[i].enumerated() {
                if values.element.key == "recipeId" {
                    recipeId = Int(values.element.value as? Int32 ?? 0)
                } else if values.element.key == "recipeName" {
                    recipeName = values.element.value as? String ?? ""
                } else if values.element.key == "imageUrl" {
                    imageUrl = values.element.value as? String ?? ""
                }
                print("recipeId: \(recipeId)")
                print("recipeName: \(recipeName)")
                print("imageUrl: \(imageUrl)")
            }
            guard let cooking = Cooking(recipeId: recipeId, recipeName: recipeName, imageUrl: imageUrl) else {
                return []
            }
            cookingArray.append(cooking)
            print("cookingArray: \(cookingArray)")
        }
        return cookingArray
    }
    
    func deleteBookMark(_ sqlValue: [SQLValue]) {
        bookMarkDataManager.delete(sqlValue)
    }
}
