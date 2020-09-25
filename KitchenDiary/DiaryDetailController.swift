//
//  DiaryDetailController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import os.log

class DiaryDetailController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var MemoText: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MemoText.layer.borderWidth = 1.0
        self.MemoText.layer.borderColor = UIColor.black.cgColor

       MemoText.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        MemoText.text = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            MemoText.resignFirstResponder()
            return false
           }
           return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { self.view.endEditing(true) }

    
    func registerForKeyboardNotification(){
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        func removeRegisterForKeyboardNotification(){
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
 
    
    @objc func keyBoardShow(notification: NSNotification){
           let userInfo: NSDictionary = notification.userInfo! as NSDictionary
           let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
           let keyboardRectangle = keyboardFrame.cgRectValue
//           if mmTextField.isEditing == true{
//               keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: mmTextField)
//           }
//           else if yyTextField.isEditing == true{
//               keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: yyTextField)
//           }
//           else if secretNumberTextField.isEditing == true{
//               keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: secretNumberTextField)
//           }
//           else if cardNickTextField.isEditing == true{
//               keyboardAnimate(keyboardRectangle: keyboardRectangle, textField: cardNickTextField)
//           }
       }
    
    
    @objc func keyboardHide(_ notification: Notification){
                self.view.transform = .identity
        }
    
    
    
    
}
