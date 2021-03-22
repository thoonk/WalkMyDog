//
//  RadioButton.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import UIKit

class RadioButton: UIButton {
    
    var alternateBtn: Array<RadioButton>?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2.0
        self.layer.masksToBounds = true
    }
    
    func unselectAlternateButtons() {
        if alternateBtn != nil {
            self.isSelected = true
            
            for aButton:RadioButton in alternateBtn! {
                aButton.isSelected = false
            }
        } else {
            toggleButton()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    func toggleButton() {
        self.isSelected = !isSelected
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.layer.borderColor = #colorLiteral(red: 0.4196078431, green: 0.4, blue: 1, alpha: 1)
            } else {
                self.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
}
