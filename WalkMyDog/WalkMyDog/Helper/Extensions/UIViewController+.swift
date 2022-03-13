//
//  UIViewController+.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/13.
//

import UIKit

extension UIViewController {
    func setupAlertView(with msg: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    func format(seconds: TimeInterval) -> String {
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02d:%02d", min, sec)
    }
    
    func setupReqAuthView() {
        let alertController = UIAlertController(
            title: "알림",
            message: "산책갈개? 앱의 권한을 허용해야 해당 기능을 사용하실 수 있습니다.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "설정", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:])
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
