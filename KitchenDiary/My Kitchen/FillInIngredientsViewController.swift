//
//  FillInIngredientsViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/10/13.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//
import UIKit

class FillInIngredientsViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ingredientsName: UITextField!
    @IBOutlet weak var storageMethod: UISegmentedControl!
    @IBOutlet weak var expirationDate: UIDatePicker!
    @IBOutlet weak var ingredientsMemo: UITextView!
    var ingredient: Ingredients?
    
    // MARK: Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
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
        
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy년 MM월 dd일"
        let exprirationDateStr = dateFomatter.string(from: expirationDate.date)
        let memo = ingredientsMemo.text ?? ""
        ingredient = Ingredients(name: name, storageMethod: storage, expirationDate: exprirationDateStr, memo: memo)
    }
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: Life Cycle
extension FillInIngredientsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsName.delegate = self
        ingredientsMemo.delegate = self
        scrollView.delegate = self
 
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
            
            let expirationDateStr: String = ingredient.expirationDate
            print("expirationDateStr: \(expirationDateStr)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            let now = NSDate()
            
            let dateStr:Date = dateFormatter.date(from:expirationDateStr) ?? now as Date
            expirationDate.date = dateStr
            
            ingredientsMemo.text = ingredient.memo
            updateSaveButtonState()
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
        
        let backwardImage = UIImage(systemName: "chevron.backward")
        let backbutton = UIBarButtonItem(image: backwardImage, style: .done, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backbutton
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}
extension FillInIngredientsViewController: UIGestureRecognizerDelegate {

}

// MARK: - UITextViewDelegate
extension FillInIngredientsViewController: UITextViewDelegate {
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
    
    //memoText.frame.height가 0보다 작으면 backspace 안되게 하기
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let originMemoTextSize = ingredientsMemo.frame.height
        if text == "" && range.length > 0 {
            if originMemoTextSize < 0 {
                return false
            }
        }
        //글자수 200으로 제한하기
        let currentText = ingredientsMemo.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 200
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let memoCount = "\(textView.text.count)"
        textCount.text = memoCount
    }
}

// MARK: - UIScrollViewDelegate
extension FillInIngredientsViewController: UIScrollViewDelegate {
    //scroll시 keyborad 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension FillInIngredientsViewController: UITextFieldDelegate {
    //textField 없을 때 저장 버튼 비활성화시키기
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.orange
        
        let barButtonItem = UIBarItem().setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor : UIColor.orange,
            ], for: .normal)
    }
    func updateSaveButtonState() {
        let text = ingredientsName.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        if saveButton.isEnabled {
            saveButton.tintColor = UIColor.orange
        }
    }
}
