//
//  KitchenDiaryUITests.swift
//  KitchenDiaryUITests
//
//  Created by 전소영 on 2020/11/27.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import XCTest
import SQLite3

class KitchenDiaryUITests: XCTestCase {
    let dataManager = DataManager.init(SQLDataInfo(dbPath: "테스트6.sqlite", tableName: "테스트테이블6", column: RecipeColumns.columnArray))
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testInsert() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1001),SQLValue(key: "recipeName", value: "감자옹심이")]))
    }
    
    func testSelect() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1009),SQLValue(key: "recipeName", value: "감자")]))
        XCTAssert(dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String")]))
    }
    
    func testDelete() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1003),SQLValue(key: "recipeName", value: "감자옹심이")]))
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1004),SQLValue(key: "recipeName", value: "피자")]))
        XCTAssert(dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String")]))
        XCTAssert(dataManager.delete([SQLValue(key: "recipeId", value: 1003)]))
        XCTAssert(dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String")]))
    }
    
    struct SQLValue {
        var key: String
        var value: Any
    }
    
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
    }
    
    struct RecipeColumns {
        var columnType: ColumnType
        static let columnArray = [ColumnArray(value: ColumnInfo(name: "recipeId", type: ColumnType.integer.rawValue, primaryKey: true)),
                                  ColumnArray(value: ColumnInfo(name: "recipeName", type: ColumnType.text.rawValue, primaryKey: false)),
                                  ColumnArray(value: ColumnInfo(name: "imageUrl", type: ColumnType.text.rawValue, primaryKey: false))]
    }
    
    class DataManager {
        var db: OpaquePointer?
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
            var keyValues: [String] = []
            for i in 0..<paramValues.count {
                keyValues.append(paramValues[i].key)
            }
            let columns = keyValues.joined(separator: ", ") // recipeId, recipeName, imageUrl
            var questionString = "?"
            for _ in 0..<paramValues.count-1 {
                questionString.append(", ?")
            }
            let insertStatementString = "INSERT INTO \(tableName) (\(columns)) VALUES (\(questionString));"
            print("insertStatementString: \(insertStatementString)")
            var stmt: OpaquePointer? //query를 가리키는 포인터
            var returnBool: Bool = false
            
            if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
                for (index,values) in paramValues.enumerated() {
                    if let intValue = values.value as? Int {
                        print("intValue: \(intValue)")
                        sqlite3_bind_int(stmt, Int32(index+1), Int32(intValue))
                    } else if let stringValue = values.value as? String {
                        print("stringValue: \(stringValue)")
                        sqlite3_bind_text(stmt, Int32(index+1), stringValue, -1, nil)
                    }
                }
                if sqlite3_step(stmt) == SQLITE_DONE {
                    print("\nInsert row Success")
                } else {
                    print("\nInsert row Faild")
                }
                returnBool = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                print("\nInsert Statement is not prepared")
            }
            sqlite3_finalize(stmt)
            return returnBool
        }
        
        func select(_ paramValues: [SQLValue]) -> Bool {
            var resultArray = paramValues
            var keyValues: [String] = []
            for i in 0..<paramValues.count {
                keyValues.append(paramValues[i].key)
            }
            let columns = keyValues.joined(separator: ", ")
            
            let queryStatementString = "SELECT \(columns) FROM \(tableName);"
            print("queryStatementString : \(queryStatementString)" )
            var queryStatement: OpaquePointer? = nil
            var returnBool: Bool = false
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
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
                        }
                    }
                    print("resultArray : \(resultArray)")
                }
                returnBool = true
            } else {
                print("SELECT statement could not be prepared")
            }
            sqlite3_finalize(queryStatement)
            return returnBool
        }
        
        func delete(_ paramValues: [SQLValue]) -> Bool {
            var paramString: String = ""
            var paramValue: Int = 0
            for i in 0..<paramValues.count {
                paramString = paramValues[i].key
                paramValue = paramValues[i].value as? Int ?? 0
            }
            let deleteStatementStirng = "DELETE FROM \(tableName) WHERE \(paramString) = ?;"
            print("deleteStatementStirng: \(deleteStatementStirng)")
            var deleteStatement: OpaquePointer? = nil
            var isSuccess = false
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
                if let intValue = paramValue as? Int {
                    print("delete intValue: \(intValue)")
                    sqlite3_bind_int(deleteStatement, 1, Int32(intValue))
                } else if let stringValue = paramValue as? String {
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
            return isSuccess
        }
    }
}
