//
//  Debouncer.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

class Debouncer: NSObject {
    var callback: () -> Void
    var delay: Double
    weak var timer: Timer?

    init(delay: Double, callback: @escaping () -> Void) {
        self.delay = delay
        self.callback = callback
    }

    func fire() {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(toCallback), userInfo: nil, repeats: false)
        timer = nextTimer
    }

    @objc func toCallback() {
        callback()
    }
}
