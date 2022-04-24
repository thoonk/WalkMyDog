//
//  TimerService.swift
//  WalkMyDog
//
//  Created by thoonk on 2022/03/13.
//

import Foundation

protocol TimerServiceDelegate: AnyObject {
    func timerTick(_ currentTi: Double)
}

final class TimerService {
    private var timer: Timer?
    weak var delegate: TimerServiceDelegate?
    
    var currentTime: Double = 0.0
    private(set) var isRunning = false
    
    init() {}
    
    func startTimer() {
        guard self.isRunning == false else { return }
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        self.isRunning = true
    }
    
    @objc
    func updateTimer() {
        self.currentTime += 0.01
        self.delegate?.timerTick(self.currentTime)
    }
    
    func pauseTimer() {
        guard self.isRunning else { return }
        self.timer?.invalidate()
        self.isRunning = false
    }
}
