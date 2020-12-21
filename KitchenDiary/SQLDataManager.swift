//
//  SQLDataManager.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/25.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import Foundation
import sqlite3

struct SQLDataInfo {
    let dbPath: String
    let tableName: String
    let column: [ColumnArray]
}

struct ColumnArray {
    let value: ColumnInfo
}

struct ColumnInfo {
    let name: String
    let type: String
    let primaryKey: Bool
}

enum ColumnType: String {
    case text = "TEXT"
    case integer = "INTEGER"
    case blob = "BLOB"
}

struct SQLValue {
    var key: String
    var value: Any
}

public class SQLDataManager {
    var db: OpaquePointer?
    let queue = DispatchQueue(label: "dataQueue")
    var dbPath = ""
    var tableName = ""
    var column: [ColumnArray] = []
    var insertParamValuesArray: [Any] = []
    var returnArray: [Any] = []
    var returnArrays: [[Any]] = []
    
    init(_ sqlDataInfo: SQLDataInfo){
        self.dbPath = sqlDataInfo.dbPath
        self.tableName = sqlDataInfo.tableName
        self.column = sqlDataInfo.column
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
        var columnString = ""
        for i in 0..<column.count {
            columnString.append(column[i].value.name + " ")
            columnString.append(column[i].value.type + " ")
            if column[i].value.primaryKey == true {
                columnString.append("PRIMARY KEY")
            }
            if i != column.count-1 {
                columnString.append(", ")
            }
        }
        
        let createTableString = "CREATE TABLE IF NOT EXISTS \(tableName)(\(columnString));"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("createTableString: \(createTableString)")
                print("\(tableName) table created.")
            } else {
                print("\(tableName) table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    @discardableResult
    func insert(_ paramValues: [SQLValue]) -> Bool {
        var paramkeyValues: [String] = []
        for i in 0..<paramValues.count {
            paramkeyValues.append(paramValues[i].key)
        }
        let columns = paramkeyValues.joined(separator: ", ") // recipeId, recipeName, imageUrl
        var questionString = "?"
        for _ in 0..<paramValues.count-1 {
            questionString.append(", ?")
        }
        let insertStatementString = "INSERT INTO \(tableName) (\(columns)) VALUES (\(questionString));"
        print("insertStatementString: \(insertStatementString)")
        var stmt: OpaquePointer? //query를 가리키는 포인터
        var isSuccess: Bool = false
        queue.sync {
            if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
                for (index,values) in paramValues.enumerated() {
                    if let intValue = values.value as? Int {
                        print("intValue: \(intValue)")
                        sqlite3_bind_int(stmt, Int32(index+1), Int32(intValue))
                    } else if let stringValue = values.value as? NSString {
                        print("stringValue: \(stringValue)")
                        
                        sqlite3_bind_text(stmt, Int32(index+1), stringValue.utf8String, -1, nil)
                    } else if let blobValue = values.value as? UIImage {
                        guard let data = blobValue.pngData() as NSData? else {
                            return
                        }
                        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                        sqlite3_bind_blob(stmt, Int32(index+1), data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                    }
                }
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("\nInsert row Success")
                } else {
                    print("\nInsert row Faild")
                }
                isSuccess = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                print("\nInsert Statement is not prepared")
            }
            sqlite3_finalize(stmt)
        }
        return isSuccess
    }
    
    @discardableResult
    func update(_ paramValues: [SQLValue], _ whereValues: [SQLValue]) -> Bool {
        var columns: String = ""
        for i in 0..<paramValues.count {
            columns.append(paramValues[i].key)
            columns.append(" = ?, ")
        }
        columns = String(columns.dropLast(2))
    
        var wherePrase: String = ""
        for i in 0..<whereValues.count {
            wherePrase.append(whereValues[i].key)
            wherePrase.append(" = ?, ")
        }
        wherePrase = String(wherePrase.dropLast(2))
        let updateStatementString =  "UPDATE \(tableName) SET \(columns) WHERE \(wherePrase);"
        print("updateStatementString: \(updateStatementString)")
        var stmt: OpaquePointer? //query를 가리키는 포인터
        var isSuccess: Bool = false
        queue.sync {
            if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
                var commonIndex = 0
                for (index,values) in paramValues.enumerated() {
                    if let intValue = values.value as? Int {
                        print("intValue: \(intValue)")
                        sqlite3_bind_int(stmt, Int32(index+1), Int32(intValue))
                    } else if let stringValue = values.value as? NSString {
                        print("stringValue: \(stringValue)")
                        
                        sqlite3_bind_text(stmt, Int32(index+1), stringValue.utf8String, -1, nil)
                    } else if let blobValue = values.value as? UIImage {
                        guard let data = blobValue.pngData() as NSData? else {
                            return
                        }
                        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                        sqlite3_bind_blob(stmt, Int32(index+1), data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                    }
                    commonIndex = index+1
                    print("commonIndex: \(commonIndex)")
                }
                for (index,values) in whereValues.enumerated() {
                    print("whereValues commonIndex: \(commonIndex)")
                    if let intValue = values.value as? Int {
                        print("intValue: \(intValue)")
                        sqlite3_bind_int(stmt, Int32(commonIndex+1), Int32(intValue))
                    } else if let stringValue = values.value as? NSString {
                        print("stringValue: \(stringValue)")
                        
                        sqlite3_bind_text(stmt, Int32(commonIndex+1), stringValue.utf8String, -1, nil)
                    } else if let blobValue = values.value as? UIImage {
                        guard let data = blobValue.pngData() as NSData? else {
                            return
                        }
                        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                        sqlite3_bind_blob(stmt, Int32(commonIndex+1), data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                    }
                }
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("\nUpdate row Success")
                } else {
                    print("\nUpdate row Faild")
                }
                isSuccess = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing nUpdate: \(errmsg)")
                print("\nUpdate Statement is not prepared")
            }
            sqlite3_finalize(stmt)
        }
        return isSuccess
    }
    
    func select(_ paramValues: [SQLValue], _ whereValues: [SQLValue]) -> [[SQLValue]] {
        var resultArray = paramValues
        var resultArrays: [[SQLValue]] = []
        var keyValues: [String] = []
        for i in 0..<paramValues.count {
            keyValues.append(paramValues[i].key)
        }
        let columns = keyValues.joined(separator: ", ")
        var queryStatementString = "SELECT \(columns) FROM \(tableName)"
        if whereValues[0].key != "nil" {
            queryStatementString.append(" WHERE ")
            for i in 0..<whereValues.count {
                queryStatementString.append(whereValues[i].key)
                queryStatementString.append(" = ?,")
            }
            queryStatementString = String(queryStatementString.dropLast(1))
        }
        queryStatementString.append(";")
        print("queryStatementString : \(queryStatementString)")
        var queryStatement: OpaquePointer? = nil
        queue.sync {
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                
                for (index,values) in whereValues.enumerated() {
                    if let intValue = values.value as? Int {
                        print("intValue: \(intValue)")
                        sqlite3_bind_int(queryStatement, Int32(index+1), Int32(intValue))
                    } else if let stringValue = values.value as? NSString {
                        print("stringValue: \(stringValue)")
                        
                        sqlite3_bind_text(queryStatement, Int32(index+1), stringValue.utf8String, -1, nil)
                    } else if let blobValue = values.value as? UIImage {
                        guard let data = blobValue.pngData() as NSData? else {
                            return
                        }
                        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                        sqlite3_bind_blob(queryStatement, Int32(index+1), data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                    }
                }
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    for i in 0..<paramValues.count {
                        print("i: \(i)")
                        if paramValues[i].value as? String == "Int" {
                            var intValue: Int32
                            intValue = sqlite3_column_int(queryStatement, Int32(i))
                            print("intValue : \(intValue)")
                            resultArray[i].value = intValue
                        } else if paramValues[i].value as? String == "String" {
                            var stringValue: String = ""
                            stringValue = String(describing: String(cString: sqlite3_column_text(queryStatement, Int32(i))))
                            print("stringValue : \(stringValue)")
                            resultArray[i].value = stringValue
                        } else if paramValues[i].value as? String == "UIImage" {
                            let image = sqlite3_column_blob(queryStatement, 1);
                            let image_length = sqlite3_column_bytes(queryStatement, 1);
                            let imageData = NSData(bytes: image, length: Int(image_length))
                            
                            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                            let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
                            resultArray[i].value = UIImage(data: dataDecoded)
                        }
                    }
                    print("resultArray : \(resultArray)")
                    resultArrays.append(resultArray)
                    print("resultArrays: \(resultArrays)")
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
        }
        return resultArrays
    }
    
    @discardableResult
    func delete(_ whereValues: [SQLValue]) -> Bool {
        var whereString: String = ""
        var whereValue: Int = 0
        var stringWhereValue = ""
        for i in 0..<whereValues.count {
            whereString = whereValues[i].key
            whereValue = whereValues[i].value as? Int ?? 0
            if ((whereValues[i].value as? String) != nil) {
                stringWhereValue = String(whereValue)
            }
        }
        let deleteStatementStirng = "DELETE FROM \(tableName) WHERE \(whereString) = ?;"
        print("deleteStatementStirng: \(deleteStatementStirng)")
        var deleteStatement: OpaquePointer? = nil
        var isSuccess = false
        queue.sync {
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                if let intValue = whereValue as? Int {
                    print("delete intValue: \(intValue)")
                    sqlite3_bind_int(deleteStatement, 1, Int32(intValue))
                } else if let stringValue = stringWhereValue as? String {
                    sqlite3_bind_text(deleteStatement, 1, stringValue, -1, nil)
                }
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    print("successfully deleted row.")
                } else {
                    print("Could not delete row.")
                }
                isSuccess = true
            } else {
                print("DELETE statement could not be prepared")
            }
            sqlite3_finalize(deleteStatement)
        }
        return isSuccess
    }
}
