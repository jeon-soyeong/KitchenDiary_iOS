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
    
    @IBOutlet weak var memoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var memoText: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textCount: UILabel!
    @IBOutlet weak var memoTextBottom: NSLayoutConstraint!
    
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
               
      //  memoText.isScrollEnabled = false
        textViewDidChange(memoText)
    }
    
    private let maxHeight: CGFloat = 100
    
    private var isOversized = false {
          didSet {
              guard oldValue != isOversized else {
                  return
              }
              
            //memoText.easy.reload()
            memoText.isScrollEnabled = isOversized
            memoText.setNeedsUpdateConstraints()
          }
      }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.contentSize.height >= maxHeight {
            memoText.isScrollEnabled = true
                }
        
//        let size = CGSize(width: view.frame.width, height: .infinity)
//        let estimatedSize = textView.sizeThatFits(size)
//        textView.constraints.forEach { (constraint) in
//            if constraint.firstAttribute == .height {
//                constraint.constant = estimatedSize.height
//                self.view.layoutIfNeeded()
//            }
//        }
//
        let memoCount = "\(textView.text.count)"
        textCount.text = memoCount
      
       // viewHeight.constant = textView.frame.maxY + memoTextBottom.constant
            
//        var memoTextHeight = memoText.contentSize.height
//
//        print("memoText.contentSize.height: \(memoText.contentSize.height)")
//        memoHeight.constant = memoTextHeight

 
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //줄 띄우기
//        if text == "\n" {
//            scrollView.contentSize.height += memoText.font?.pointSize ?? 0
//            viewHeight.constant += memoText.font?.pointSize ?? 0
//        }
        
        //backspace 클릭시 textvivew size가 줄었으면
        var originMemoTextSize = memoText.frame.height
       //var newMemoTextSize = originMemoTextSize - memoText.font!.pointSize ?? 0
        if text == "" && range.length > 0 {
            
//            if (memoText.contentSize.height > memoText.frame.size.height) {
//
//                memoText.sizeToFit()
//                memoText.layoutIfNeeded()
//
//            }
      
            
           // if viewHeight.constant != memoText.frame.maxY + memoTextBottom.constant {

//            if originMemoTextSize == newMemoTextSize {
//                print("originMemoTextSize: \(originMemoTextSize)")
//                print("newMemoTextSize: \(newMemoTextSize)")
        //        viewHeight.constant -= memoText.font?.pointSize ?? 0
//                originMemoTextSize = newMemoTextSize
          //}
            
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
