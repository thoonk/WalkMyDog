//
//  UIViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import UIKit

extension UIViewController {
    /// 키보드 위에 완료 버튼을 추가하는 함수
    func setKeyboardDoneBtn(for action: Selector) -> UIToolbar {
        let bar = UIToolbar()
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "완료", style: .done, target: self, action: action)
        bar.items = [leftSpace, doneBtn]
        bar.tintColor = .black
        bar.sizeToFit()
        return bar
    }
    /// 추가하고 싶은 단위를 입력하여 라벨을 추가하는 함수
    func setUnitLabel(inTxtField text: String) -> UILabel {
        let unitLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        unitLabel.font = UIFont(name: "NanumGothicCoding", size: 18)
        unitLabel.text = text
        return unitLabel
    }
    
    /// 페이지의 뒤로가는 버튼을 커스텀하는 함수
    func setCustomBackBtn() {
        let backImg = UIImage(systemName: "chevron.backward")?
            .resized(to: CGSize(width: 20, height: 20))
        let leftItem = UIBarButtonItem(
            image: backImg,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        leftItem.tintColor = UIColor(named: "customTintColor")
        self.navigationItem.leftBarButtonItem = leftItem        
    }
    
    @objc
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
