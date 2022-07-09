//
//  Defaults.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/07/09.
//

import Foundation

class Defaults {
    private enum DefaultKeys: String {
        case backgroundTime
        case timerStatus
    }
    
    static let shared = Defaults()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    func set(backgroundTime: Date) {
        defaults.set(backgroundTime, forKey: DefaultKeys.backgroundTime.rawValue)
    }
    
    func getBackgroundTime() -> Date? {
        defaults.object(forKey: DefaultKeys.backgroundTime.rawValue) as? Date
    }
    
    func set(timerStatus: TimerStatus) {
        defaults.set(timerStatus.rawValue, forKey: DefaultKeys.timerStatus.rawValue)
    }
    
    func getTimerStatus() -> TimerStatus {
        TimerStatus(rawValue: defaults.integer(forKey: DefaultKeys.timerStatus.rawValue))!
    }
    
    func synchronize() {
        defaults.synchronize()
    }
}
