//
//  ResTimer.swift
//  ResTimer
//
//  Created by Taylor Geisse on 5/25/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import Foundation

protocol ResTimerDelegate: AnyObject {
    func timerFired(identifer: String)
}

class ResTimer {
    private var isStopped = true
    private var accumulatedTime = 0.0
    private var startingTime: Date?
    private var timer: Timer?
    weak var delegate: ResTimerDelegate?
    var identifier = ""
    
    private var timeSinceStarting: Double {
        guard let startTime = startingTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    var interval: Double = 1.0 {
        didSet {
            if !isStopped {
                stop()
                start()
            }
        }
    }
    
    var runningTime: Double {
        return accumulatedTime + (isStopped ? 0 : timeSinceStarting)
    }
    
    enum TimerState {
        case running
        case paused
        case stopped
    }
    
    var state: TimerState {
        if isStopped {
            if startingTime != nil { return .paused }
            else { return .stopped }
        } else {
            return .running
        }
    }
    
    func start() {
        if !isStopped { return }
        
        startingTime = Date()
        
        let timeToNextUpdate = interval - accumulatedTime.truncatingRemainder(dividingBy: interval)
        
        if timeToNextUpdate == 0 { timerLoopStart() }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: timeToNextUpdate, repeats: false) { [weak self] _ in
                self?.delegate?.timerFired(identifer: self?.identifier ?? "")
                self?.timerLoopStart()
            }
        }
        
        isStopped = false
    }
    
    private func timerLoopStart() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.delegate?.timerFired(identifer: self?.identifier ?? "")
        }
        isStopped = false // redundant in most cases, but is good for safe measures
    }
    
    func stop() {
        if isStopped { return }
        
        timer?.invalidate()
        accumulatedTime += timeSinceStarting
        isStopped = true
    }
    
    func reset() {
        if !isStopped { stop() }
        adjustAccumulatedTime(to: 0.0)
        startingTime = nil
    }
    
    func adjustAccumulatedTime(to: Double) {
        accumulatedTime = to
    }
    
    deinit {
        timer?.invalidate()
    }
}
