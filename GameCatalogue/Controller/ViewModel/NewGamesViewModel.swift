//
//  NewGamesViewModel.swift
//  GameCatalogue
//
//  Created by Jamal on 12/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

protocol NewGamesViewModelDelegate: class {
    func fetchDidComplete()
    func fetchDidFail(with cause: Any)
}

final class NewGamesViewModel {
    private weak var delegate: NewGamesViewModelDelegate?

    private var newGames = [Game]()
    private var page = 1
    private var isFetching = false
    private var loadMore = true

    private let client = Client()

    init(delegate: NewGamesViewModelDelegate) {
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
        newGames.count
    }

    func game(at index: Int) -> Game {
        newGames[index]
    }

    func fetchNewGames(refresh: Bool = false) {
        guard !isFetching || refresh else { return }
        var thePage = page
        if refresh { thePage = 1 }
        isFetching = true

        var queryItems = [(String, String)]()

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let thisMonth = formatter.string(from: date)

        if let lastMonthFormatter = Calendar.current.date(byAdding: .month, value: -1, to: date) {
            let lastMonth = formatter.string(from: lastMonthFormatter)
            queryItems.append(("dates", "\(lastMonth),\(thisMonth)"))
        }

        queryItems.append(("page", String(thePage)))

        client.fetchGames(queueLabel: "fetchNewGames", queryItems: queryItems) { result in
            switch result {
            case let .success(response):
                DispatchQueue.main.async {
                    if refresh { self.page = 1 }
                    if self.page == 1 { self.newGames = [] }
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

                        self.newGames.append(Game(id: game.id, name: game.name, imagePath: game.imagePath, genreList: genres, released: released, rating: rating, parentPlatformNames: platforms))
                    }

                    if self.newGames.count != 0 {
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
