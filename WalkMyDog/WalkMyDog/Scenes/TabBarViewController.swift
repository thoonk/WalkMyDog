//
//  TabBarViewController.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/02.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupAttributes()
    }
    
    func setupTabBar() {
        let mainViewController = MainViewController()
        //UINavigationController(rootViewController: MainViewController())
        
        let walkReadyViewController = WalkReadyViewController()
        
        setViewControllers(
            [
                mainViewController,
                walkReadyViewController
            ],
            animated: false
        )
        
        let main = UITabBarItem(title: "홈", image: nil, tag: 0)
        let walk = UITabBarItem(title: "산책", image: nil, tag: 1)
        let checkList = UITabBarItem(title: "체크리스트", image: nil, tag: 2)
        
        mainViewController.tabBarItem = main
        walkReadyViewController.tabBarItem = walk
    }
    
    func setupAttributes() {
        self.selectedIndex = 0
        let customFont = UIFont(name: "NanumSquareRoundR", size: 15.0) ?? UIFont.systemFont(ofSize: 15.0)
        self.tabBar.items?[0].title = "홈"
        self.tabBar.items?[1].title = "산책"
//        self.tabBar.items?[2].title = "체크리스트"
        
        self.tabBar.items?[0].setTitleTextAttributes(
            [NSAttributedString.Key.font: customFont],
            for: .normal
        )
        self.tabBar.items?[1].setTitleTextAttributes(
            [NSAttributedString.Key.font: customFont],
            for: .normal
        )
//        self.tabBar.items?[2].setTitleTextAttributes(
//            [NSAttributedString.Key.font: customFont!],
//            for: .normal
//        )
        
        tabBar.isTranslucent = false
        tabBar.barTintColor = .white
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor(hex: "979797").cgColor

        self.tabBar.tintColor = UIColor(named: "customTintColor")
        LocationManager.shared.requestAuthroization()
    }
}
