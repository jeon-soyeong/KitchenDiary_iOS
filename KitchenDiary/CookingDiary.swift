//
//  CookingDiary.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/30.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class CookingDiary: NSObject {
    //, NSCoding
    //MARK: Properties
    var cookingName: String
    var cookingPhoto: UIImage?
    var cookingRating: Int
    var cookingMemo: String
    var cookingIndex: Int
    
//    //MARK: Archiving Paths
//    static let DoumentsDirectory = FileManager().urls(for: .documentDirectory, in:.userDomainMask).first!
//    static let ArchiveURL = DoumentsDirectory.appendingPathComponent("cookingDiaries")
    
//    //MARK: Types
//    struct  PropertyKey {
//        static let cookingName = "cookingName"
//        static let cookingPhoto = "cookingPhoto"
//        static let cookingRating = "cookingRating"
//        static let cookingMemo = "cookingMemo"
//    }
    
    //MARK: Initialization
    init?(cookingName: String, cookingPhoto: UIImage?, cookingRating: Int, cookingMemo: String, cookingIndex: Int) {
        guard !cookingName.isEmpty || !cookingMemo.isEmpty else {
            return nil
        }
        guard (cookingRating >= 0) && (cookingRating <= 5) else {
            return nil
        }
        guard cookingIndex >= 0 else {
            return nil
        }
        self.cookingName = cookingName
        self.cookingPhoto = cookingPhoto
        self.cookingRating = cookingRating
        self.cookingMemo = cookingMemo
        self.cookingIndex = cookingIndex
    }
    convenience init(cookingName: String, cookingPhoto: UIImage?, cookingRating: Int, cookingMemo: String) {
        self.init(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating:  cookingRating, cookingMemo: cookingMemo)
        
    }
    
//    //MARK: NSCoding  --> 데이터 지속성과 관련됨
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(cookingName, forKey: PropertyKey.cookingName)
//        aCoder.encode(cookingPhoto, forKey: PropertyKey.cookingPhoto)
//        aCoder.encode(cookingRating, forKey: PropertyKey.cookingRating)
//        aCoder.encode(cookingMemo, forKey: PropertyKey.cookingMemo)
//    }
//
//    required convenience init?(coder aDecoder: NSCoder) {
//
//        //The name is required. if we cannot decode a name string, the initailizer should fail.
//        guard let cookingName = aDecoder.decodeObject(forKey: PropertyKey.cookingName) as? String else {
//            return nil
//        }
//
//        //Becuase photo is an optional property of Meal, just use conditional cast.
//        let cookingPhoto = aDecoder.decodeObject(forKey: PropertyKey.cookingPhoto) as? UIImage
//
//        let cookingRating = aDecoder.decodeInteger(forKey: PropertyKey.cookingRating)
//
//        guard let cookingMemo = aDecoder.decodeObject(forKey: PropertyKey.cookingMemo) as? String else {
//            return nil
//        }
//
//        //Must call designated initailizer.
//        self.init(cookingName: cookingName, cookingPhoto: cookingPhoto, cookingRating: cookingRating, cookingMemo: cookingMemo)
//    }
}
