//
//  GamesViewModel.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

protocol GamesViewModelDelegate: class {
    func fetchDidComplete()
    func fetchDidFail(with cause: Any)
}

final class GamesViewModel {
    private weak var delegate: GamesViewModelDelegate?

    private var games = [Game]()
    private var page = 1
    private var isFetching = false
    private var loadMore = true

    private let client = Client()

    init(delegate: GamesViewModelDelegate) {
        self.delegate = delegate
    }

    var isLoading: Bool {
        get {
            isFetching
        }
        set {
            isFetching = newValue
        }
    }

    var shouldLoadMore: Bool {
        loadMore
    }

    var count: Int {
        games.count
    }

    func game(at index: Int) -> Game {
        games[index]
    }

    func fetchGames(refresh: Bool = false) {
        guard !isFetching || refresh else { return }
        var thePage = page
        if refresh { thePage = 1 }
        isFetching = true

        let queryItems = [("page", String(thePage))]

        client.fetchGames(queueLabel: "fetchGames", queryItems: queryItems) { result in
            switch result {
            case let .success(response):
                DispatchQueue.main.async {
                    if refresh { self.page = 1 }
                    if self.page == 1 { self.games = [] }
                    self.page += 1
                    self.isFetching = false
                    response.games.forEach { game in

                        var genres = [String]()
                        if let responseGenres = game.genres {
                            responseGenres.forEach { genre in
                                if let genreName = genre.name {
                                    genres.append(genreName)
                                }
                            }
                        }

                        var released = ""
                        if let responseReleased = game.released {
                            released = responseReleased
                        }

                        var rating: Double = 0
                        if let responseRating = game.rating {
                            rating = responseRating * 2
                        }

                        var platforms = Set<String>()
                        if let responseParentPlatforms = game.parentPlatforms {
                            responseParentPlatforms.forEach { parentPlatforms in
                                if let responsePlatform = parentPlatforms.platform {
                                    if let responseSlug = responsePlatform.slug {
                                        platforms.insert(responseSlug)
                                    }
                                }
                            }
                        }

                        self.games.append(Game(id: game.id, name: game.name, imagePath: game.imagePath ?? "", genreList: genres, released: released, rating: rating, parentPlatformNames: platforms))
                    }

                    if self.games.count != 0 {
                        self.loadMore = true
                    } else {
                        self.loadMore = false
                    }

                    self.delegate?.fetchDidComplete()
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    self.isFetching = false
                    if error.reason == 404 {
                        self.loadMore = false
                    } else {
                        self.loadMore = true
                    }
                    self.delegate?.fetchDidFail(with: error.reason)
                }
            }
        }
    }

    func cancelTask() {
        client.cancelMainTask()
    }
}
