//
//  RadioButton.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/22.
//

import UIKit

/// 라디오 버튼 구현 클래스
final class RadioButton: UIButton {
    
    var alternateBtn: Array<RadioButton>?
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
                self.layer.borderColor = UIColor(named: "customTintColor")?.cgColor
            } else {
                self.layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
}
