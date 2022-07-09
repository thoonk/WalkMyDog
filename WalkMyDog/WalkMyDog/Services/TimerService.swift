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

enum TimerStatus: Int {
    case ready = 0
    case run = 1
    case pause = 2
}

final class TimerService {
    private var timer: Timer?
    weak var delegate: TimerServiceDelegate?
    
    var currentTime: Double = 0.0
    private(set) var isRunning = false
    var isPaused = false
    
    init() {}
    
    func startTimer(with backgroundTime: Int = 0) {
        guard (self.isRunning && !self.isPaused) == false
        else { return }
        
        if isPaused == true {
            isPaused = false
            resetTimer(with: backgroundTime)
        }
        
        isRunning = true
        Defaults.shared.set(timerStatus: .run)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimer() {
        self.currentTime += 0.01
        self.delegate?.timerTick(self.currentTime)
    }
    
    func pauseTimer() {
        guard self.isRunning else { return }
        self.timer?.invalidate()
        self.isPaused = true
        Defaults.shared.set(timerStatus: .pause)
    }
    
    func stopTimer() {
        guard self.isRunning else { return }
        
        isRunning = false
        isPaused = false
        timer?.invalidate()
    }
    
    func resetTimer(with backgroundTime: Int) {
        let elapsedTime = Double(backgroundTime)
        self.currentTime += elapsedTime
    }
}
