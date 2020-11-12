//
//  CookingEvaluationDataManager.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/01.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation
import sqlite3

public class CookingEvaluationDataManager {
    static let shared: CookingEvaluationDataManager = CookingEvaluationDataManager.init()
    let queue = DispatchQueue(label: "dataQueue")
    
    let dbPath: String = "CookingEvaluation.sqlite"
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
        let createTableString = "CREATE TABLE IF NOT EXISTS CookingEvaluation(cookingName TEXT,cookingPhoto BLOB,cookingRating INTEGER,cookingMemo TEXT, todayDate TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("CookingEvaluation table created.")
            } else {
                print("CookingEvaluation table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insertCookingEvaluations(_ cookingName: String, _ cookingPhoto: UIImage, _ cookingRating: Int, _ cookingMemo: String, _ todayDate: String) {
        let insertStatementString = "INSERT INTO CookingEvaluation (cookingName, cookingPhoto, cookingRating, cookingMemo, todayDate) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer? //query를 가리키는 포인터
        queue.sync {
            print("insert cooking : \(cookingName), \(cookingPhoto), \(cookingRating), \(cookingMemo)")
            guard let data = cookingPhoto.pngData() as NSData? else {
                return
            }
            let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_text(stmt, 1, cookingName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_blob(stmt, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                sqlite3_bind_int(stmt, 3, Int32(cookingRating))
                sqlite3_bind_text(stmt, 4, cookingMemo, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(stmt, 5, todayDate, -1, SQLITE_TRANSIENT)
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("\nInsert row Success")
                } else {
                    print("\nInsert row Faild")
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                print("\nInsert Statement is not prepared")
            }
            sqlite3_finalize(stmt)
        }
    }
   
    
    func updateCookingEvaluations(_ cookingName: String, _ cookingPhoto: UIImage, _ cookingRating: Int, _ cookingMemo: String, _ cookingIndex: Int) {
        
        let updateStatementString =  "UPDATE CookingEvaluation SET cookingName = ?, cookingPhoto = ?, cookingRating = ?, cookingMemo = ? WHERE rowid = ?;"
        var stmt: OpaquePointer? //query를 가리키는 포인터
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
            guard let data = cookingPhoto.pngData() as NSData? else {
                return
            }
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            print("전달받은 cookingName: \(cookingName)")
            print("전달받은 cookingPhoto: \(cookingPhoto)")
            print("전달받은 cookingRating: \(cookingRating)")
            print("전달받은 cookingMemo: \(cookingMemo)")
            print("전달받은 cookingIndex: \(cookingIndex)")
            sqlite3_bind_text(stmt, 1, cookingName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_blob(stmt, 2, data.bytes, Int32(data.length), SQLITE_TRANSIENT)
            sqlite3_bind_int(stmt, 3, Int32(cookingRating))
            sqlite3_bind_text(stmt, 4, cookingMemo, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(stmt, 5, Int32(cookingIndex))
            
            if sqlite3_step(stmt) == SQLITE_DONE{
                print("\nUpdate row Success")
                print("updateStatement: \(updateStatementString)")
            }else{
                print("\nUpdate row Faild")
            }
        }else{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: \(errmsg)")
            print("\nUpdate Statement is not prepared")
        }
        sqlite3_finalize(stmt)
    }
    
    
    func readCookingEvaluations(_ todayDate: String) -> [CookingDiary] {
        let queryStatementString = "SELECT *, rowid FROM CookingEvaluation WHERE todayDate = ?;"
        var queryStatement: OpaquePointer?
        var cookingDiaries : [CookingDiary] = []
        
        queue.sync {
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                sqlite3_bind_text(queryStatement, 1, todayDate, -1, SQLITE_TRANSIENT)
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    
                    let cookingName = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                    print("cookingName : \(cookingName)")
                    let image = sqlite3_column_blob(queryStatement, 1);
                    let image_length = sqlite3_column_bytes(queryStatement, 1);
                    let imageData = NSData(bytes: image, length: Int(image_length))
                    
                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                    let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    let cookingPhoto = UIImage(data: dataDecoded)
                    
                    let cookingRating = sqlite3_column_int(queryStatement, 2)
                    print("cookingRating : \(cookingRating)")
                    let cookingMemo = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                    print("cookingMemo : \(cookingMemo)")
                    let todayDate = String(describing: String(cString: sqlite3_column_text(queryStatement, 4)))
                    print("todayDate : \(todayDate)")
                    let cookingIndex = sqlite3_column_int(queryStatement, 5)
                    print("cookingIndex : \(cookingIndex)")
                    
                   
                    guard let cookingDiary = CookingDiary(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating: Int(cookingRating), cookingMemo: cookingMemo, cookingIndex: Int(cookingIndex)) else {
                        fatalError("no cookingDiary")
                    }
                    cookingDiaries.append(cookingDiary)
                    print("Query Result:")
                    print("\(cookingName) | \(cookingPhoto) | \(cookingRating) | \(cookingMemo) | \(cookingIndex) | \(todayDate)")
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
        return cookingDiaries
    }
    
    func deleteByCookingIndex(cookingIndex: Int) {
        let deleteStatementStirng = "DELETE FROM CookingEvaluation WHERE rowid = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(cookingIndex))
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
