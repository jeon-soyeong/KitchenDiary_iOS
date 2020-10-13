//
//  FillInIngredientsController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/13.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//
import UIKit

class FillInIngredientsController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var memoText: UITextView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var nameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoText.delegate = self
        scrollView.delegate = self
        
        memoText.layer.borderWidth = 1.0
        memoText.layer.borderColor = UIColor.black.cgColor
        
        registerForKeyboardNotification()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        textViewDidChange(memoText)
    }
}

extension FillInIngredientsController: UITextViewDelegate {
    
    func registerForKeyboardNotification(){
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue { UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height) }) }
        
        //이름 수정시 화면고정
        if nameText.isEditing {
            UIView.animate(withDuration: 0, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: 0) })
        }
    }

    @objc func keyboardHide(_ notification: Notification) {
        self.view.transform = .identity
    }
    
    //tap시 keyborad 내리기
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
            self.view.endEditing(true)
    }
    
    //memoText.frame.height이 0보다 작으면 backspace 안되게 하기
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let originMemoTextSize = memoText.frame.height
        if text == "" && range.length > 0 {
            if originMemoTextSize < 0 {
                return false
            }
        }
        
        //글자수 200으로 제한하기
        let currentText = memoText.text ?? ""

       // attempt to read the range they are trying to change, or exit if we can't
       guard let stringRange = Range(range, in: currentText) else { return false }

       // add their new text to the existing text
       let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
    
       // make sure the result is under 200 characters
       return updatedText.count <= 200
    }
    
    //memo 글자수 세기
    func textViewDidChange(_ textView: UITextView) {
        let memoCount = "\(textView.text.count)"
        textCount.text = memoCount
    }
}

extension FillInIngredientsController: UIScrollViewDelegate {
    //scroll시 keyborad 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.view.endEditing(true)
    }
}
