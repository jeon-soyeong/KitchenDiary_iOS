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
    let dataManager = SQLDataManager.init(SQLDataInfo(dbPath: "테스트6.sqlite", tableName: "테스트테이블6", column: RecipeColumns.columnArray))
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsert() throws {
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1001),SQLValue(key: "recipeName", value: "감자옹심이")]))
    }
    
    func testSelect() throws {
        let selectResult = dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String")],[SQLValue(key: "nil", value: "")])
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1009),SQLValue(key: "recipeName", value: "감자")]))
        XCTAssert(selectResult.isEmpty == false)
    }
    
    func testDelete() throws {
        let selectResult = dataManager.select([SQLValue(key: "recipeId", value: "Int"),SQLValue(key: "recipeName", value: "String")],[SQLValue(key: "nil", value: "")])
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1003),SQLValue(key: "recipeName", value: "감자옹심이")]))
        XCTAssert(dataManager.insert([SQLValue(key: "recipeId", value: 1004),SQLValue(key: "recipeName", value: "피자")]))
        XCTAssert(selectResult.isEmpty == false)
        XCTAssert(dataManager.delete([SQLValue(key: "recipeId", value: 1003)]))
        XCTAssert(selectResult.isEmpty == false)
    }
}
