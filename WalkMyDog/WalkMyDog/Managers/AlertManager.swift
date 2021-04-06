//
//  AlertManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/03/22.
//

import Foundation
import RxSwift

class AlertManager {
    // MARK: - Properties
    static let shared = AlertManager()
    
    private init() {}
    
    // MARK: - Methods
    func showAlert(title: String, subTitle: String, actionBtnTitle: String, cancelBtnTitle: String? = nil, completion: (() -> Void)? = nil) -> AlertViewController {
        let stotyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        let alertVC = stotyboard.instantiateViewController(identifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        alertVC.alertSubTitle = subTitle
        alertVC.actionBtnTitle = actionBtnTitle
        alertVC.cancelBtnTitle = cancelBtnTitle
        alertVC.onActionBtn = completion
        return alertVC
    }
}
