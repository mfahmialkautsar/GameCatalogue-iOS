//
//  ImageOperation.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

class ImageOperation {
    let queueName: String
    let maxOps: Int

    init(queueName: String, maxOps: Int = 7) {
        self.queueName = queueName
        self.maxOps = maxOps
    }

    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = self.queueName
        queue.maxConcurrentOperationCount = self.maxOps
        return queue
    }()
}
