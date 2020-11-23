//
//  SQLDataManager.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/25.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation
import sqlite3

public class SQLDataManager {
    let dbPath: String = "CookingBookMark.sqlite"
    var db: OpaquePointer?
    
    init(){
        db = openDatabase()
        createTable()
    }
    
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
            return nil
        }
        else {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS Cooking(recipeId INTEGER PRIMARY KEY,recipeName TEXT,imageUrl TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("cooking table created.")
            } else {
                print("cooking table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertCookings(_ recipeId : Int, _ recipeName: String, _ imageUrl: String) {
        //(1) insert sql문
        let insertStatementString = "INSERT INTO Cooking (recipeId, recipeName, imageUrl) VALUES (?, ?, ?);"
        //(2) 쿼리 저장 변수
        var stmt: OpaquePointer? //query를 가리키는 포인터
        let recipeId = Int32(recipeId)
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK{
            
            sqlite3_bind_int(stmt, 1, recipeId)
            sqlite3_bind_text(stmt, 2, recipeName, -1, nil)
            sqlite3_bind_text(stmt, 3, imageUrl, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE{
                print("\nInsert row Success")
            }else{
                print("\nInsert row Faild")
            }
        }else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            print("\nInsert Statement is not prepared")
        }
        sqlite3_finalize(stmt)
    }
    
//    insert(tableName: "cooking", values: ["recipeId": "aa"])
//    func insert(tableName: String, values: [String: Any]) {
//        //(1) insert sql문
//        let columns = values.keys.joined(separator: ",") // recipeId, recipeName, imageUrl
//        let insertStatementString = "INSERT INTO \(tableName) ("\(columns)") VALUES (?, ?, ?);"
//        //(2) 쿼리 저장 변수
//        var stmt: OpaquePointer? //query를 가리키는 포인터
//        let recipeId = Int32(recipeId)
//
//        if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK{
//            for index, value in values.enumerated() {
//                if let intValue = value as? Int {
//                    sqlite3_bind_int(stmt, index + 1, intValue)
//                } else if stringValue = value as? String {
//
//                }
//            }
//            sqlite3_bind_text(stmt, 2, recipeName, -1, nil)
//            sqlite3_bind_text(stmt, 3, imageUrl, -1, nil)
//
//            if sqlite3_step(stmt) == SQLITE_DONE{
//                print("\nInsert row Success")
//            }else{
//                print("\nInsert row Faild")
//            }
//        }else{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing insert: \(errmsg)")
//            print("\nInsert Statement is not prepared")
//        }
//        sqlite3_finalize(stmt)
//        //return Int(sqlite3_last_insert_rowid(db))
//    }
    
    func readCookings() -> [Cooking] {
        let queryStatementString = "SELECT * FROM Cooking;"
        var queryStatement: OpaquePointer? = nil
        var cookings : [Cooking] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let recipeId = sqlite3_column_int(queryStatement, 0)
                let recipeName = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let imageUrl = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                guard let cooking = Cooking(recipeId: Int(recipeId), recipeName: recipeName, imageUrl: imageUrl) else {
                    fatalError("no cooking")
                }
                cookings.append(cooking)
                print("Query Result:")
                print("\(recipeId) | \(recipeName) | \(imageUrl)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return cookings
    }
    
    func deleteByRecipeId(recipeId: Int) {
        let deleteStatementStirng = "DELETE FROM Cooking WHERE recipeId = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(recipeId))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
}
