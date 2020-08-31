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
    func fetchDidFail(cause: (code: Int, description: String))
}

final class DetailViewModel {
    private weak var delegate: DetailViewModelDelegate?
    private var gameProvider = GameProvider.sharedInstance

    init(delegate: DetailViewModelDelegate) {
        self.delegate = delegate
    }

    let client = Client()

    func fetchDetail(id: Int) {
        cancelTask()
        client.fetchDetail(queueLabel: "fetchDetail", id: id) { result in
            switch result {
            case let .success(response):
                DispatchQueue.main.async {
                    var description = ""
                    if let descResponse = response.description {
                        description = descResponse
                    } else {
                        description = ""
                    }

                    var developers = [String]()
                    if let devResponse = response.developers {
                        devResponse.forEach { dev in
                            if let devName = dev.name {
                                developers.append(devName)
                            }
                        }
                    }

                    self.delegate?.fetchDidComplete(response: Detail(description: description, developers: developers))
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.delegate?.fetchDidFail(cause: error.reason)
                }
            }
        }
    }

    private func cancelTask() {
        client.cancelDetailTask()
    }

    func favorite(game: Game, completion: @escaping (Result<Game?, ErrorResponse>) -> Void) {
        if isFavorited(id: game.id) {
            gameProvider.deleteFavorite(id: game.id) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        completion(Result.success(nil))
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        completion(Result.failure(error))
                    }
                }
            }
        } else {
            gameProvider.addFavorite(game: game) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        completion(Result.success(nil))
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        completion(Result.failure(error))
                    }
                }
            }
        }
    }

    func isFavorited(id: Int) -> Bool {
        return gameProvider.getFavorite().filter({ $0.id == id }).first != nil
    }
}
