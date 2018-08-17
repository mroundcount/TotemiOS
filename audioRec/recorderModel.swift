//
//  recorderModel.swift
//  audioRec
//
//  Created by Michael Roundcount on 8/16/18.
//  Copyright © 2018 Michael Roundcount. All rights reserved.
//

import UIKit

struct randomNumber {
    var rand: String?
}

class recorder {
    
    func random() -> String {
        var rand = Int(arc4random_uniform(3))
        
        switch rand {
        case 0:
            rand = 1
            return "you got 1"
        case 1:
            rand = 2
            return "you got 2"
        case 2:
            rand = 3
            return "you got 3"
        default:
            rand = 0
            return "you got 0"
        }
    }
    
    func openingTxt() -> String {
        var rand = Int(arc4random_uniform(5))
        
        switch rand {
        case 0:
            rand = 1
            return "Hey there big fella. Touch me anywhere to start recording"
        case 1:
            rand = 2
            return "Be a mensch and click the screen ehhh"
        case 2:
            rand = 3
            return " 'Quitting smoking is easy, I've done it a dozen times' - Mark Twain"
        case 3:
            rand = 4
            return " 'The three Fs you need to survive in life: Food, Friends, Fun... well maybe there's a fourth F' - Woz  "
        case 4:
            rand = 5
            return " If there is anything Count hates it's people who are afraid to use his app... that an American Airlines "
        default:
            rand = 0
            return "you got 0"
        }
    }
    
}

class timer {
    
    //Timer variables
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0
    var status: Bool = false
    var event: String?
    
    //Timer functions
    func start() {
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        // Set Start/Stop button to true
        status = true
    }
    
    func stop() {
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        // Set Start/Stop button to false
        status = false
    }
    
    @objc func updateCounter() {
        // Calculate total time since timer started in seconds
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        // Calculate minutes
        let minutes = UInt8(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        // Calculate seconds
        let seconds = UInt8(time)
        time -= TimeInterval(seconds)
        
        // Calculate milliseconds
        let milliseconds = UInt8(time * 100)
        
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMilliseconds = String(format: "%02d", milliseconds)
        
        
        // Add time vars to relevant labels
        print("\(strMinutes):\(strSeconds):\(strMilliseconds)")
        
        func eventTimer() -> String {
            if seconds <= 3 {
                return "You'll do great"
            } else if seconds >= 10 && seconds <= 12 {
                return "Start talking buddy"
            } else if seconds >= 30 && seconds <= 32 {
                return "Seriously hurry the fuck up"
            } else {
                return " "
            }
        }
        print(eventTimer())
    }
}

class recording {
    
    
}




