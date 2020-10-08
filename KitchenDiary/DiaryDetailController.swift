//
//  DiaryDetailController.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/24.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit
import os.log

class DiaryDetailController: UIViewController, UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MemoText: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
   
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var MemoTextHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MemoText.layer.borderWidth = 1.0
        self.MemoText.layer.borderColor = UIColor.black.cgColor
        MemoText.delegate = self
        scrollView.delegate = self
        
        placeholderSetting()
        registerForKeyboardNotification()
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        photoImageView.isUserInteractionEnabled = true
               
        MemoText.delegate = self
        MemoText.isScrollEnabled = false
        textViewDidChange(MemoText)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                self.view.layoutIfNeeded()
                print("'MemoTextHeight: \(estimatedSize.height)")
                print("'MemoText.font?.pointSize ?? 0: \(MemoText.font?.pointSize ?? 0)")
            }
        }
    }
    
    @IBOutlet weak var bottomAnchor: NSLayoutConstraint!
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            scrollView.contentSize.height += MemoText.font?.pointSize ?? 0
            ViewHeight.constant += MemoText.font?.pointSize ?? 0

            print("ViewHeight: \(ViewHeight)")
            print("scrollview : \(scrollView.contentSize.height)")
        }
        
        //backspace버튼 클릭시
        if text == "" && range.length > 0 {
            print("backspace!!")
            ViewHeight.constant -= MemoText.font?.pointSize ?? 0
            
            print("ViewHeight: \(ViewHeight)")
            print("scrollview : \(scrollView.contentSize.height)")
        }
        
        if MemoText.text.length
        
        return true
    }
    
    
    
    //tap시 keyborad 내리기
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
            self.view.endEditing(true)
    }
    
    //scroll시 keyborad 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
            self.view.endEditing(true)
    }
    
    func placeholderSetting() {
        MemoText.text = "Memo"
        MemoText.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            textView.textAlignment = .left
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Memo."
            textView.textColor = UIColor.lightGray
            textView.textAlignment = .center
        }
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

//extension DiaryDetailController:  {
//
//
