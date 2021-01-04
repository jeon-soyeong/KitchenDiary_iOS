//
//  SQLDatabaseManagerTests.swift
//  KitchenDiaryTests
//
//  Created by 전소영 on 2021/01/04.
//  Copyright © 2021 Soyeong Jeon. All rights reserved.
//

import XCTest
import SQLite3
@testable import KitchenDiary

class SQLDatabaseManagerTests: XCTestCase {
    let dataManager = SQLDatabaseManager.init(SQLDataInfo(dbPath: "Test.sqlite", tableName: "Test테이블", column: RecipeColumns.columnArray))
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataManager.deleteAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() throws {
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1001),SQLValue(key: "recipeName", value: "감자옹심이"),SQLValue(key: "imageUrl", value: "imageUrl")]))
    }
    
    func testSelect() throws {
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1009),SQLValue(key: "recipeName", value: "감자"),SQLValue(key: "imageUrl", value: "imageUrl")]))
        let selectResult = dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String"),SQLValue(key: "imageUrl", value: "String")],[SQLValue(key: "nil", value: "")])
        XCTAssert(selectResult.isEmpty == false)
        XCTAssert(selectResult.count == 1)
    }
    
    func testDelete() throws {
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1003),SQLValue(key: "recipeName", value: "감자옹심이"),SQLValue(key: "imageUrl", value: "imageUrl")]))
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1004),SQLValue(key: "recipeName", value: "피자"),SQLValue(key: "imageUrl", value: "imageUrl")]))
        let selectResult = dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String"),SQLValue(key: "imageUrl", value: "String")],[SQLValue(key: "nil", value: "")])
        XCTAssert(selectResult.isEmpty == false)
        XCTAssert(dataManager.delete([SQLValue(key: "recipeId", value: 1003)]))
        let selectResult2 = dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String"),SQLValue(key: "imageUrl", value: "String")],[SQLValue(key: "nil", value: "")])
        XCTAssert(selectResult2.count == 1)
    }
}
