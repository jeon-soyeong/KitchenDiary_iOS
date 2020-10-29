//
//  DiaryDetailController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import os.log

class DiaryDetailController: UIViewController {
    
    @IBOutlet weak var memoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var memoText: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var memoTextBottom: NSLayoutConstraint!
    @IBOutlet weak var cookingName: UITextField!
    var recipeName: String?
    
    // tabBar 이동
    @IBAction func goToKitchenDiary(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
        
        //창 닫기
        if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The DiaryDetailController is not inside a navigation controller.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memoText.layer.borderWidth = 1.0
        self.memoText.layer.borderColor = UIColor.black.cgColor
        memoText.delegate = self
        scrollView.delegate = self
        
        registerForKeyboardNotification()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        photoImageView.isUserInteractionEnabled = true
        
        textViewDidChange(memoText)
        
        cookingName.text = recipeName
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
       }

    @objc func keyboardHide(_ notification: Notification){
        self.view.transform = .identity
    }
    
    //memo 글자수 세기
    func textViewDidChange(_ textView: UITextView) {
        let memoCount = "\(textView.text.count)"
        textCount.text = memoCount
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
            present(imagePickerController, animated:  true, completion:  nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage

        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
}
