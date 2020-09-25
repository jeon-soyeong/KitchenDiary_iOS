//
//  MemoTextFunc.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class MemoTextFunc: NSObject, UITextFieldDelegate {
    
    //MARK: UITextFieldDelegate
    //return이 눌릴 때 호출
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        //return key의 press를 process해야하는지에 대한 여부
        return true
    }
    
      //편집 or 키보드가 표시될 때 호출
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         
    }
}
