//
//  DiaryDetailController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import os.log

class DiaryDetailViewModel {
    var cookingDiary: CookingDiary?
    
    func update(model: CookingDiary?) {
        cookingDiary = model
    }
}

class DiaryDetailController: UIViewController {
    var recipeName: String?
    var cookingDiary: CookingDiary?
    var saveButtonMode: String?
    let viewModel = DiaryDetailViewModel()
    
    @IBOutlet weak var cookingName: UITextField!
    @IBOutlet weak var cookingPhoto: UIImageView!
    @IBOutlet weak var cookingRating: RatingControl!
    @IBOutlet weak var cookingMemoText: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var memoHeight: NSLayoutConstraint!
    @IBOutlet weak var memoTextBottom: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    // tabBar 이동
    @IBAction func goToKitchenDiary(_ sender: UIBarButtonItem) {
        
        let name = cookingName.text ?? ""
        guard let photo = cookingPhoto.image else {
            return
        }
        let rating = cookingRating.rating
        let memo = cookingMemoText.text ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        let selectDateString = dateFormatter.string(from: Date())
        
        //DB 저장하기
        let cookingEvaluationDataManager = CookingEvaluationDataManager.shared
        if saveButtonMode == "save" {
            
            let userDefaults = UserDefaults.standard
            if let eventDictionary = UserDefaults.standard.object(forKey: "eventDictionary") as? Data {
                guard let eventDatesDictionary = NSKeyedUnarchiver.unarchiveObject(with: eventDictionary) as? [String : Int] else {
                    return
                }
                print("eventDatesDictionary: \(eventDatesDictionary)")
                CalendarDiaryViewController.eventDatesDictionary = eventDatesDictionary
            }
            print("CalendarDiaryViewController.eventDatesDictionary: \(CalendarDiaryViewController.eventDatesDictionary)")
            print("CalendarDiaryViewController.eventDatesDictionary[selectDateString]: \(CalendarDiaryViewController.eventDatesDictionary[selectDateString])")
            var dicCount = CalendarDiaryViewController.eventDatesDictionary[selectDateString]
            if dicCount == nil {
                dicCount = 0
            }
            print("dicCount: \(dicCount)")
            CalendarDiaryViewController.eventDatesDictionary.updateValue(dicCount!+1, forKey: selectDateString)
            let eventDictionary = try? NSKeyedArchiver.archivedData(withRootObject: CalendarDiaryViewController.eventDatesDictionary, requiringSecureCoding: false)
            UserDefaults.standard.set(eventDictionary, forKey: "eventDictionary")
            print("dicCount update: \(CalendarDiaryViewController.eventDatesDictionary[selectDateString])")
            print("CalendarDiaryViewController.eventDatesDictionary : \(CalendarDiaryViewController.eventDatesDictionary)")
            
            cookingEvaluationDataManager.insertCookingEvaluations(name, photo, rating, memo, selectDateString)
        }
        if saveButtonMode == "edit" {
            guard let index = viewModel.cookingDiary?.cookingIndex else {
                return
            }
            cookingEvaluationDataManager.updateCookingEvaluations(name, photo, rating, memo, index)
        }
        
        //창 닫기
        if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The DiaryDetailController is not inside a navigation controller.")
        }
        //tabBar 이동하기
        self.tabBarController?.selectedIndex = 3
    }
    
    func updateUI() {
        if let cookingDiary = viewModel.cookingDiary {
            cookingName.text = cookingDiary.cookingName
            print("cookingDiary.cookingName: \(cookingDiary.cookingName)")
            print("updateUI cookingDiary.cookingIndex: \(cookingDiary.cookingIndex)")
            cookingPhoto.image = cookingDiary.cookingPhoto
            cookingRating.rating = cookingDiary.cookingRating
            cookingMemoText.text = cookingDiary.cookingMemo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        self.cookingMemoText.layer.borderWidth = 1.0
        self.cookingMemoText.layer.borderColor = UIColor.black.cgColor
        cookingMemoText.delegate = self
        scrollView.delegate = self
        
        registerForKeyboardNotification()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        cookingPhoto.isUserInteractionEnabled = true
        
        textViewDidChange(cookingMemoText)
        
        cookingName.placeholder = recipeName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            print("saveButton 호출")
            os_log ( "The save button was not pressed, cancelling" , log : OSLog . default , type : . debug )
            return
        }
        let name = cookingName.text ?? ""
        let photo =  cookingPhoto.image
        let rating = cookingRating.rating
        let memo = cookingMemoText.text ?? ""
        guard let index = cookingDiary?.cookingIndex else {
            return
        }
        guard let todayDate = cookingDiary?.todayDate else {
            return
        }
        print("DiaryDetail cookingDiary : \(name), \(photo), \(rating), \(memo), \(index)")
        // 보낼
        cookingDiary = CookingDiary(cookingName: name, cookingPhoto: photo, cookingRating: rating, cookingMemo: memo, cookingIndex: index, todayDate: todayDate)
    }
}

extension DiaryDetailController: UITextViewDelegate {
    //tap시 keyborad 내리기
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func registerForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardShow(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue { UIView.animate(withDuration: 0.3, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height) }) }
        
        //제목 입력시 화면고정
        if cookingName.isEditing {
            UIView.animate(withDuration: 0, animations: { self.view.transform = CGAffineTransform(translationX: 0, y: 0) })
        }
    }
    
    @objc func keyboardHide(_ notification: Notification){
        self.view.transform = .identity
    }
    
    //memo 글자수 세기
    func textViewDidChange(_ textView: UITextView) {
        let memoCount = "\(textView.text.count)"
        textCount.text = memoCount
    }
    
    //cookingMemoText.frame.height이 0보다 작으면 backspace 안되게 하기
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let originMemoTextSize = cookingMemoText.frame.height
        if text == "" && range.length > 0 {
            if originMemoTextSize < 0 {
                return false
            }
        }
        
        //글자수 200으로 제한하기
        let currentText = cookingMemoText.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under 200 characters
        return updatedText.count <= 200
    }
}

extension DiaryDetailController: UIScrollViewDelegate {
    //scroll시 keyborad 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension DiaryDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        //image를 가져올 위치를 지정(enum type)
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set cookingPhoto to display the selected image.
        cookingPhoto.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}
