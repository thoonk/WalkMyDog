//
//  TabBarViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/02.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 0
        let customFont = UIFont(name: "NanumGothic", size: 13)
        self.tabBar.items?[0].title = "산책 기록"
        self.tabBar.items?[1].title = "날씨 예보"
        
        self.tabBar.items?[0].setTitleTextAttributes(
            [NSAttributedString.Key.font: customFont!],
            for: .normal
        )
        self.tabBar.items?[1].setTitleTextAttributes(
            [NSAttributedString.Key.font: customFont!],
            for: .normal
        )

        self.tabBar.tintColor = UIColor(named: "customTintColor")
        LocationManager.shared.requestAuthroization()
    }
}
