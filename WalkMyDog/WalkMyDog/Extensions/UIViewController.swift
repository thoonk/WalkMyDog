//
//  UIViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit

extension UIViewController {
    
    func setKeyboardDoneBtn(for action: Selector) -> UIToolbar {
        let bar = UIToolbar()
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "완료", style: .done, target: self, action: action)
        bar.items = [leftSpace, doneBtn]
        bar.tintColor = .black
        bar.sizeToFit()
        return bar
    }
}
