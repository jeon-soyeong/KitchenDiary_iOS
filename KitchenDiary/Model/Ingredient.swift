//
//  Ingredient.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/14.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class Ingredient: NSObject, NSCoding {
    var name: String
    var storageMethod: String
    var expirationDate: String
    var memo: String?
    
    //MARK: Archiving Paths
    static let DoumentsDirectory = FileManager().urls(for: .documentDirectory, in:.userDomainMask).first!
    static let ArchiveURL = DoumentsDirectory.appendingPathComponent("ingredients")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let storageMethod = "storageMethod"
        static let expirationDate = "expirationDate"
        static let memo = "memo"
    }
       
    init?(name: String, storageMethod: String, expirationDate: String, memo: String?) {
        guard !name.isEmpty else {
            return nil
        }
        guard !storageMethod.isEmpty else {
            return nil
        }
        guard !expirationDate.isEmpty else {
            return nil
        }
        self.name = name
        self.storageMethod = storageMethod
        self.expirationDate = expirationDate
        self.memo = memo
    }
    
    //MARK: NSCoding  --> 데이터 지속성과 관련됨
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(storageMethod, forKey: PropertyKey.storageMethod)
        aCoder.encode(expirationDate, forKey: PropertyKey.expirationDate)
        aCoder.encode(memo, forKey: PropertyKey.memo)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            return nil
        }
        guard let storageMethod = aDecoder.decodeObject(forKey: PropertyKey.storageMethod) as? String else {
            return nil
        }
        guard let expirationDate = aDecoder.decodeObject(forKey: PropertyKey.expirationDate) as? String else {
            return nil
        }
        guard let memo = aDecoder.decodeObject(forKey: PropertyKey.memo) as? String else {
            return nil
        }
        self.init(name: name, storageMethod: storageMethod, expirationDate: expirationDate, memo: memo)
    }
}
