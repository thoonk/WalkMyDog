//
//  UIViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String, _ msg: String) {
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "확인", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
}
