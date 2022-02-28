//
//  SceneDelegate.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/02.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        initialVC = storyBoard.instantiateViewController(identifier: "LoginVC")
        
        let initialVC = storyBoard.instantiateViewController(identifier: "TabBarVC")
        
//        if let user = Auth.auth().currentUser {
//            print("You're sign in as \(user.uid), email: \(user.email ?? "no email")")
//            initialVC = storyBoard.instantiateViewController(identifier: "TabBarVC")
//        } else {
//            initialVC = storyBoard.instantiateViewController(identifier: "LoginVC")
//        }
        
        if (UserDefaults.standard.value(forKey: "pmRcmdCriteria") as? String) == nil {
            UserDefaults.standard.setValue("좋음", forKey: "pmRcmdCriteria")
        }
        
        self.window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.window?.rootViewController = initialVC
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

