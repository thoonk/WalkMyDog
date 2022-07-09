//
//  NotificationCenterProtocol.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/07/09.
//

import RxSwift

protocol NotificationCenterProtocol {
    var name: Notification.Name { get }
}

extension NotificationCenterProtocol {
    func addObserver() -> Observable<Any?> {
        return NotificationCenter.default.rx.notification(self.name).map { $0.object }
    }
    
    func post(object: Any? = nil) {
        NotificationCenter.default.post(
            name: self.name,
            object: object
        )
    }
}

enum ApplicationNotificationCenter: NotificationCenterProtocol {
    case willEnterForeground
    case didEnterBackground
    
    var name: Notification.Name {
        switch self {
        case .willEnterForeground:
            return UIApplication.willEnterForegroundNotification
            
        case .didEnterBackground:
            return UIApplication.didEnterBackgroundNotification
        }
    }
}
