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
    
    let dbPath: String = "CookingEvaluation.sqlite"
    var db:OpaquePointer?
    
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
        let createTableString = "CREATE TABLE IF NOT EXISTS CookingEvaluation(cookingName TEXT,cookingPhoto BLOB,cookingRating INTEGER,cookingMemo TEXT);"
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
        
    
    func insertCookingEvaluations(_ cookingName: String, _ cookingPhoto: UIImage, _ cookingRating: Int, _ cookingMemo: String) {
           //(1) insert sql문
           let insertStatementString = "INSERT INTO CookingEvaluation (CookingName, CookingPhoto, CookingRating, CookingMemo) VALUES (?, ?, ?, ?);"
           //(2) 쿼리 저장 변수
           var stmt: OpaquePointer? //query를 가리키는 포인터
           guard let data = cookingPhoto.pngData() as NSData? else {
                return
           }
       
           if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {

            sqlite3_bind_text(stmt, 1, cookingName, -1, nil)
            sqlite3_bind_blob(stmt, 2, data.bytes, Int32(data.length), nil)
            sqlite3_bind_int(stmt, 3, Int32(cookingRating))
            sqlite3_bind_text(stmt, 4, cookingMemo, -1, nil)
             
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
    
    func readCookingEvaluations() -> [CookingDiary] {
            let queryStatementString = "SELECT *, rowid FROM CookingEvaluation;"
            var queryStatement: OpaquePointer? = nil
            var cookingDiaries : [CookingDiary] = []
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let cookingName = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                    print("select cookingName: \(cookingName)")
                    
                    let image = sqlite3_column_blob(queryStatement, 1);
                    let image_length = sqlite3_column_bytes(queryStatement, 1);
                    let imageData = NSData(bytes: image, length: Int(image_length))
                  
                    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                    
                    let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                    let cookingPhoto = UIImage(data: dataDecoded)
                  
                    let cookingRating = sqlite3_column_int(queryStatement, 2)
                    let cookingMemo = String(describing: String(cString: sqlite3_column_text(queryStatement, 3)))
                    let cookingIndex = sqlite3_column_int(queryStatement, 4)
                 
                    guard let cookingDiary = CookingDiary(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating: Int(cookingRating), cookingMemo: cookingMemo, cookingIndex: Int(cookingIndex)) else {
                        fatalError("no cookingDiary")
                    }
                    
                    cookingDiaries.append(cookingDiary)
                    print("Query Result:")
                    print("\(cookingName) | \(cookingPhoto) | \(cookingRating) | \(cookingMemo) | \(cookingIndex) ")
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
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
