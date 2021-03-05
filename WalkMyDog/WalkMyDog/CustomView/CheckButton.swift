//
//  CheckButton.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/05.
//

import UIKit

class CheckButton: UIButton {
    
    let checkedImage = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedImage = UIImage(systemName: "circle")
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.isChecked = false
        self.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc
    func buttonTapped(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
