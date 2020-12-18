//
//  CookingDiaryDataManager.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/12/16.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation
import UIKit

struct CookingDiaryColumns {
    var columnType: ColumnType
    static let columnArray = [ColumnArray(value: ColumnInfo(name: "cookingName", type: ColumnType.text.rawValue, primaryKey: true)),
                              ColumnArray(value: ColumnInfo(name: "cookingPhoto", type: ColumnType.blob.rawValue, primaryKey: false)),
                              ColumnArray(value: ColumnInfo(name: "cookingRating", type: ColumnType.integer.rawValue, primaryKey: false)),
                              ColumnArray(value: ColumnInfo(name: "cookingMemo", type: ColumnType.text.rawValue, primaryKey: false)),
                              ColumnArray(value: ColumnInfo(name: "todayDate", type: ColumnType.text.rawValue, primaryKey: false))]
}

class CookingDiaryDataManager {
    var cookingDiaryDataManager: SQLDataManager
    init() {
        cookingDiaryDataManager = SQLDataManager.init(SQLDataInfo(dbPath: "CookingDiary.sqlite", tableName: "CookingDiary", column: CookingDiaryColumns.columnArray))
    }
    func insertCookingDiary(_ paramValue: [SQLValue]) {
        cookingDiaryDataManager.insert(paramValue)
    }
    func updateCookingDiary(_ paramValue: [SQLValue], _ whereValue: [SQLValue]) {
        cookingDiaryDataManager.update(paramValue, whereValue)
    }
    func selectCookingDiary(_ paramValue: [SQLValue], _ whereValue: [SQLValue]) -> [CookingDiary] {
        let selectCookingDiaryArray = cookingDiaryDataManager.select(paramValue, whereValue)
        var cookingName = ""
        var cookingPhoto: UIImage?
        var cookingRating = 0
        var cookingMemo = ""
        var todayDate = ""
        var rowid = 0
        var cookingDiaryArray: [CookingDiary] = []
        for i in 0..<selectCookingDiaryArray.count {
            print("selectCookingDiaryArray[i]: \(selectCookingDiaryArray[i])")
            for (values) in selectCookingDiaryArray[i].enumerated() {
                if values.element.key == "cookingRating" {
                    cookingRating = Int(values.element.value as? Int32 ?? 0)
                } else if values.element.key == "cookingName" {
                    cookingName = values.element.value as? String ?? ""
                } else if values.element.key == "cookingPhoto" {
                    cookingPhoto = values.element.value as? UIImage
                } else if values.element.key == "cookingMemo" {
                    cookingMemo = values.element.value as? String ?? ""
                } else if values.element.key == "todayDate" {
                    todayDate = values.element.value as? String ?? ""
                } else if values.element.key == "rowid" {
                    rowid = Int(values.element.value as? Int32 ?? 0)
                }
            }
            guard let cookingDiary = CookingDiary(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating: cookingRating, cookingMemo: cookingMemo, cookingIndex: rowid, todayDate: todayDate) else {
                return []
            }
            cookingDiaryArray.append(cookingDiary)
        }
        return cookingDiaryArray
    }
   
    func selectEventDate(_ paramValue: [SQLValue], _ whereValue: [SQLValue]) -> [String] {
        let selectEventDateArray = cookingDiaryDataManager.select(paramValue, whereValue)
        var eventDatesArrays: [String] = []
        for i in 0..<selectEventDateArray.count {
            for values in selectEventDateArray[i].enumerated() {
                eventDatesArrays.append(values.element.value as? String ?? "")
            }
        }
        return eventDatesArrays
    }
    
    func selectRowId(_ paramValue: [SQLValue], _ whereValue: [SQLValue]) -> Set<Int32> {
        let selectRowIdArray = cookingDiaryDataManager.select(paramValue, whereValue)
        var rowIdArrays: Set<Int32> = []
        for i in 0..<selectRowIdArray.count {
            for values in selectRowIdArray[i].enumerated() {
                rowIdArrays.insert(values.element.value as? Int32 ?? 0)
                for index in rowIdArrays {
                    print("set: \(index)")
                }
            }
        }
        print("rowIdArrays.count: \(rowIdArrays.count)")
        return rowIdArrays
    }
    
    func deleteByCookingIndex(_ whereValue: [SQLValue]){
        cookingDiaryDataManager.delete(whereValue)
    }
}
