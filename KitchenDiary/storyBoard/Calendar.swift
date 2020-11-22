//
//  Calendar.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/11/13.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class Calendar: UIView {

    class func instanceFromNib() -> UIView {
           return UINib(nibName: "Calendar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
       }

}
