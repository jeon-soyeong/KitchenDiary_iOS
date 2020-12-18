//
//  DiaryDetailViewController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

class DiaryDetailViewController: UIViewController {
    var recipeName: String?
    var cookingDiary: CookingDiary?
    var saveButtonMode: String?
    let viewModel = DiaryDetailViewModel()
    let cookingDiaryDataManager = CookingDiaryDataManager.init()
    var selectRowIdCount = 0
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
    
    func updateUI() {
        if let cookingDiary = viewModel.cookingDiary {
            cookingName.text = cookingDiary.cookingName
            cookingPhoto.image = cookingDiary.cookingPhoto
            cookingRating.rating = cookingDiary.cookingRating
            cookingMemoText.text = cookingDiary.cookingMemo
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
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
        cookingDiary = CookingDiary(cookingName: name, cookingPhoto: photo, cookingRating: rating, cookingMemo: memo, cookingIndex: index, todayDate: todayDate)
    }
}

// MARK: Life Cycle
extension DiaryDetailViewController {
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
        selectRowIdCount = cookingDiaryDataManager.selectRowId([SQLValue(key: "rowid", value: "Int")],[SQLValue(key: "nil", value: "nil")]).count
//        selectRowIdCount = cookingDiaryDataManager.selectRowId().count
        print("불러온 selectRowIdCount: \(selectRowIdCount)")
    }
}

// MARK: IBAction
extension DiaryDetailViewController {
    @IBAction func goToKitchenDiary(_ sender: UIBarButtonItem) {
        let name = cookingName.text ?? ""
        guard let photo = cookingPhoto.image else {
            return
        }
        let rating = cookingRating.rating
        let memo = cookingMemoText.text ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY년 MM월 dd일"
        let todayDateString = dateFormatter.string(from: Date())
        
        //DB 저장하기
        if saveButtonMode == "save" {
            CalendarDiaryViewController.eventDatesDictionary.updateValue(selectRowIdCount+1, forKey: todayDateString)
            print("+1 CalendarDiaryViewController.eventDatesDictionary: \(CalendarDiaryViewController.eventDatesDictionary)")
            cookingDiaryDataManager.insertCookingDiary([SQLValue(key: "cookingName", value: name), SQLValue(key: "cookingPhoto", value: photo), SQLValue(key: "cookingRating", value: rating), SQLValue(key: "cookingMemo", value: memo), SQLValue(key: "todayDate", value: todayDateString)])
        }
        if saveButtonMode == "edit", let index = viewModel.cookingDiary?.cookingIndex {
            print("index: \(index)")
            cookingDiaryDataManager.updateCookingDiary([SQLValue(key: "cookingName", value: name), SQLValue(key: "cookingPhoto", value: photo), SQLValue(key: "cookingRating", value: rating), SQLValue(key: "cookingMemo", value: memo)], [SQLValue(key: "rowid", value: index)])
        }
        //창 닫기
        if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            return
        }
        //tabBar 이동하기
        self.tabBarController?.selectedIndex = 3
    }
}

// MARK: - UITextViewDelegate
extension DiaryDetailViewController: UITextViewDelegate {
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
        if text == "" && range.length > 0, originMemoTextSize < 0 {
            return false
        }
        //글자수 200으로 제한하기
        let currentText = cookingMemoText.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= 200
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension DiaryDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        cookingPhoto.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension DiaryDetailViewController: UIScrollViewDelegate {
    //scroll시 keyborad 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
