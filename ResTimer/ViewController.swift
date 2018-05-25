//
//  ViewController.swift
//  ResTimer
//
//  Created by Taylor Geisse on 5/25/18.
//  Copyright © 2018 Taylor Geisse. All rights reserved.
//

import UIKit

extension Double {
    var timeElements: (hours: Int, minutes: Int, seconds: Int, ms: Int) {
        let ms = self.truncatingRemainder(dividingBy: 1) * 1000
        let seconds = self.truncatingRemainder(dividingBy: 60)
        let minutes = (self / 60).truncatingRemainder(dividingBy: 60)
        let hours = (self / 3600)
        
        return (Int(hours), Int(minutes), Int(seconds), Int(ms))
    }
}

class ViewController: UIViewController, ResTimerDelegate {
    // MARK: - UI Outlets
    @IBOutlet weak var majorTimeElements: UILabel!
    @IBOutlet weak var milliseconds: UILabel!
    @IBOutlet weak var fireInterval: UITextField!
    
    // MARK: - View Controller Properties
    private var timer = ResTimer()
    private var runningTime = 0.0 {
        didSet {
            let timeElements = runningTime.timeElements
            majorTimeElements.text = String(format: "%02i:%02i:%02i", timeElements.hours, timeElements.minutes, timeElements.seconds)
            milliseconds.text = String(format: "%03i", timeElements.ms)
        }
    }
    
    // MARK: - UI Actions
    @IBAction func start(_ sender: UIButton) {
        timer.start()
    }
    
    @IBAction func stop(_ sender: UIButton) {
        timer.stop()
        runningTime = timer.runningTime
    }
    
    @IBAction func reset(_ sender: UIButton) {
        let continueTimer = timer.state == .running
        timer.reset()
        runningTime = 0.0
        if continueTimer { timer.start() }
    }
    
    @IBAction func updateFireInterval(_ sender: UIButton) {
        guard let newInterval = Double(fireInterval.text ?? "fail") else { return }
        timer.interval = newInterval
    }
    
    // MARK: - ResTimerDelegate
    func timerFired(identifer: String) {
        runningTime = timer.runningTime
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        timer.delegate = self
    }
}

