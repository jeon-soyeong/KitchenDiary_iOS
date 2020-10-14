//
//  FillInIngredientsController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/13.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//
import UIKit
import os.log

class FillInIngredientsController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var ingredientsName: UITextField!
    @IBOutlet weak var storageMethod: UISegmentedControl!
    @IBOutlet weak var expirationDate: UIDatePicker!
    @IBOutlet weak var ingredientsMemo: UITextView!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
       // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
       let isPresentingInAddMealMode = presentingViewController is UINavigationController

       //모달로 닫을 때
       if isPresentingInAddMealMode {
           dismiss(animated: true, completion: nil)
       }
       //창에서 닫을 때
       else if let owningNavigationController = navigationController{
           owningNavigationController.popViewController(animated: true)
       }
       else {
           fatalError("The MealViewController is not inside a navigation controller.")
       }
   }
    
    // 받을
    var ingredient: Ingredients?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsMemo.delegate = self
        scrollView.delegate = self
        
        
        // Set up views if editing an existing Ingredients.
              if let ingredient = ingredient {

                ingredientsName.text = ingredient.name

                let storageStr = ingredient.storageMethod
                if storageStr == "냉장" {
                    storageMethod.selectedSegmentIndex = 0
                }
                else if storageStr == "냉동" {
                    storageMethod.selectedSegmentIndex = 1
                }
                else {
                    storageMethod.selectedSegmentIndex = 2
                }

                let expirationDatePick: String = ingredient.expirationDate
                //let dateFormatter = ISO8601DateFormatter()
                let dateFormatter = DateFormatter()
                let date:Date = dateFormatter.date(from:expirationDatePick)!
                expirationDate.date = date

                ingredientsMemo.text = ingredient.memo
              }

        ingredientsMemo.layer.borderWidth = 1.0
        ingredientsMemo.layer.borderColor = UIColor.black.cgColor
        
        registerForKeyboardNotification()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
        textViewDidChange(ingredientsMemo)
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

     // Configure the destination view controller only when the save button is pressed.
    guard let button = sender as? UIBarButtonItem, button === saveButton else{
     print("saveButton 호출")
      os_log ( "The save button was not pressed, cancelling" , log : OSLog . default , type : . debug )
        return
    }
        let name = ingredientsName.text ?? ""

        let storage: String
        if storageMethod.selectedSegmentIndex == 0 {
            storage = "냉장"
        }
        else if storageMethod.selectedSegmentIndex == 1 {
            storage = "냉동"
        }
        else {
            storage = "실온"
        }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let exprirationDateStr = df.string(from: expirationDate.date)

        let memo = ingredientsMemo.text ?? ""

    // 보낼
    // Set the meal to be passed to MealTableViewController after the unwind segue.
        ingredient = Ingredients(name: name , storageMethod: storage , expirationDate: exprirationDateStr, memo: memo)
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
        if ingredientsName.isEditing {
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
        
        let originMemoTextSize = ingredientsMemo.frame.height
        if text == "" && range.length > 0 {
            if originMemoTextSize < 0 {
                return false
            }
        }
        
        //글자수 200으로 제한하기
        let currentText = ingredientsMemo.text ?? ""

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
