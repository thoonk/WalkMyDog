//
//  CustomTextField.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/19.
//

import Foundation
import UIKit

/// 코드로 변경된 값을 Observe하기 위한 텍스트 필드
class CustomTextField: UITextField {
    override var text: String? {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
}
