//
//  RatingControl.swift
//  KitchenDiary
//
//  Created by 전소영 on 2020/09/23.
//  Copyright © 2020 Soyeong Jeon. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
   
   //MARK: Properties
   private var ratingButtons = [UIButton]()
   var rating = 0 {
       didSet {
           updateButtonsSelectionStates()
       }
   }
   @IBInspectable var starSize:CGSize = CGSize(width: 40.0, height: 40.0) {
       didSet {
           setupButtons()
       }
   }
   @IBInspectable var starCount: Int = 5 {
       didSet {
           setupButtons()
       }
   }
   
   //MARK: Initailization
   override init(frame: CGRect) {
       super.init(frame: frame)
       setupButtons()
   }
   
   required init(coder: NSCoder) {
       super.init(coder:  coder)
       setupButtons()
   }
   
   //MARK: Button Action
   @objc func ratingButtonTapped(button: UIButton) {
       guard let index = ratingButtons.index(of: button) else {
           fatalError("The button, \(button), is not in the ratingbButtons array: \(ratingButtons)")
       }
       //Calculate the rating of the selected button
       let selectedRating = index + 1
       
       if selectedRating == rating {
           //If the selected star represents the current rating, reset the rating to 0
           rating = 0
       } else {
           //Otherwise set the rating to the selected star
           rating = selectedRating
       }
   }
   
   private func setupButtons() {
       
       //clear any existing buttons
       for button in ratingButtons {
           //스택뷰의 관리범위로 꺼냄.
           removeArrangedSubview(button)
           //최종으로 화면에서 제거
           button.removeFromSuperview()
       }
       ratingButtons.removeAll()
       
       //Load Button Images
       let bundle = Bundle(for: type(of: self))
       let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
       let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
       let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
       
       for index in 0..<starCount {
           //Creaet the button
           let button = UIButton()
          
           //Set the button images
           button.setImage(emptyStar, for: .normal)
           button.setImage(filledStar, for: .selected)
           button.setImage(highlightedStar, for: .highlighted)
           button.setImage(highlightedStar, for: [.highlighted, .selected])
           
           //Add constraints
           //자동생성제약을 비활성화시킴
           button.translatesAutoresizingMaskIntoConstraints = false
           button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
           button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
           
           //Set the accessibility label
           button.accessibilityLabel = "Set \(index + 1) star rating"
           
           //Setup the button action
           button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
           
           //Add the button to the stack
           addArrangedSubview(button)
           
           //Add the new button to the rating button array
           ratingButtons.append(button)
       }
       //버튼이 컨트롤에 추가 될 때마다 버튼의 선택 상태를 업데이트
       updateButtonsSelectionStates()
   }
   
   private func updateButtonsSelectionStates() {
       for (index, button) in ratingButtons.enumerated() {
           //If the index of a button is less than the rating, that button should be selected.
           button.isSelected = index < rating
           
           //Set the hint string for the currntly selected star
           let hintString: String?
           if rating == index + 1 {
               hintString = "Tap to reset the raing to zero"
           } else {
               hintString = nil
           }
           
           //Calculate the value string
           let valueString: String
           switch (rating) {
           case 0:
               valueString = "No rating set"
           case 1:
                valueString = "1 star set"
           default:
               valueString = "\(rating) stars set"
           }
           
           //Assign the hint string and value string
           button.accessibilityHint = hintString
           button.accessibilityValue = valueString
       }
   }
   
}
