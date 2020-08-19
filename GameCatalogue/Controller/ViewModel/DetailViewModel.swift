//
//  DetailViewModel.swift
//  GameCatalogue
//
//  Created by Jamal on 11/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

protocol DetailViewModelDelegate: class {
    func fetchDidComplete(response: Detail)
    func fetchDidFail()
}

final class DetailViewModel {
    private weak var delegate: DetailViewModelDelegate?

    init(delegate: DetailViewModelDelegate) {
        self.delegate = delegate
    }

    let client = Client()

    func fetchDetail(id: Int) {
        client.fetchDetail(queueLabel: "fetchDetail", id: id) { result in
            switch result {
            case let .success(response):
                DispatchQueue.main.async {
                    var description = "Loading Description..."
                    var developers = "Loading Developers..."

                    if let desc = response.description {
                        description = desc
                    } else {
                        description = ""
                    }

                    if let developersData = response.developers {
                        developers = ""
                        var devCount = 0
                        developersData.forEach { dev in
                            if let devName = dev.name {
                                devCount += 1
                                if devCount == developersData.count {
                                    developers += devName
                                } else {
                                    developers += devName + ", "
                                }
                            }
                        }
                    } else {
                        developers = "Unknown Developers"
                    }

                    self.delegate?.fetchDidComplete(response: Detail(description: description, developers: developers))
                }
            case .failure:
                DispatchQueue.main.async {
                    self.delegate?.fetchDidFail()
                }
            }
        }
    }

    func cancelTask() {
        client.cancelDetailTask()
    }
}
