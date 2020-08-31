//
//  FavoriteGamesViewModel.swift
//  GameCatalogue
//
//  Created by Jamal on 26/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

protocol FavoriteGamesViewModelDelegate: class {
    func fetchDidComplete()
    func fetchDidFail(with cause: (code: Int, description: String))
}

final class FavoriteGamesViewModel {
    private weak var delegate: FavoriteGamesViewModelDelegate?
    private var gameProvider = GameProvider.sharedInstance

    private var games = [Game]()
    private var searchGames = [Game]()
    private var queue = OperationQueue()
    private var searchText = ""

    init(delegate: FavoriteGamesViewModelDelegate) {
        self.delegate = delegate
    }

    var count: Int {
        guard searchText.isEmpty else {
            return searchGames.count
        }
        return games.count
    }

    func game(at index: Int) -> Game {
        guard searchText.isEmpty else {
            return searchGame(at: index)
        }
        return games[index]
    }

    private var searchCount: Int {
        searchGames.count
    }

    private func searchGame(at index: Int) -> Game {
        searchGames[index]
    }

    var keyword: String {
        get {
            searchText
        }
        set {
            searchText = newValue
        }
    }

    lazy var search = Debouncer(delay: 0.1) {
        DispatchQueue.main.async {
            guard !self.searchText.isEmpty else {
                self.searchGames = self.games
                self.delegate?.fetchDidComplete()
                return
            }
            self.getGamesByName()
        }
    }

    private func getGamesByName() {
        queue.cancelAllOperations()
        var tempGames = [Game]()
        let query = BlockOperation {
            self.games.forEach { game in
                if let gameName = game.name?.lowercased(), gameName.contains(self.keyword.lowercased()) {
                    tempGames.append(game)
                }
            }
        }

        query.qualityOfService = .userInteractive
        query.completionBlock = {
            DispatchQueue.main.async {
                self.searchGames = tempGames
                self.delegate?.fetchDidComplete()
            }
        }
        queue.addOperation(query)
    }

    func getGames() {
        gameProvider.getAllGames { result in
            switch result {
            case let .success(games):
                DispatchQueue.main.async {
                    self.games = games
                    if !self.searchText.isEmpty {
                        self.getGamesByName()
                    }
                    self.delegate?.fetchDidComplete()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.delegate?.fetchDidFail(with: error.reason)
                }
            }
        }
    }
}
