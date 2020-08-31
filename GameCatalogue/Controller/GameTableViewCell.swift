//
//  GameTableViewCell.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameGenre: UILabel!
    @IBOutlet weak var gameRating: UILabel!
    @IBOutlet weak var gameReleaseDate: UILabel!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    private var viewModel: GameCellViewModel!
    private var gameProvider = GameProvider.sharedInstance
    var tableView: UITableView!
    var updateImageDelegate: UpdateDetailImageDelegate?

    func configure(with game: Game?, indexPath: IndexPath, operation: ImageOperation?, loadCell: Bool?) {
        guard let game = game else { return }

        setView(game: game)

        if let favIndex = gameProvider.getFavorite().firstIndex(where: { $0.id == game.id }) {
            guard game.state != .downloaded else { return }
            let favGame = gameProvider.getFavorite()[favIndex]
            game.image = favGame.image
            game.detail = favGame.detail
            game.state = .downloaded
            favGame.state = .downloaded
            setView(game: favGame)
            setView(game: game)
            finalization()
            return
        }
        
        guard let operation = operation, let loadCell = loadCell else { return }

        viewModel = GameCellViewModel(delegate: self, game: game, indexPath: indexPath, operation: operation)

        if loadCell {
            switch game.state {
            case .new:
                viewModel.fetchImage()
                loadBar.startAnimating()
                loadBar.isHidden = false
            case .downloaded, .failed:
                updateImageDelegate?.updateImage()
                loadBar.isHidden = true
                loadBar.stopAnimating()
            }
        } else {
            switch game.state {
            case .new:
                game.image = #imageLiteral(resourceName: "broken_image")
                game.state = .failed
                fetchDidFinish(at: indexPath, game: game)
            case .downloaded, .failed:
                updateImageDelegate?.updateImage()
                loadBar.isHidden = true
                loadBar.stopAnimating()
            }
        }
    }

    private func finalization() {
        loadBar.isHidden = true
        loadBar.stopAnimating()
        updateImageDelegate?.updateImage()
    }

    private func setView(game: Game) {
        game.genres = ""
        var genreCount = 0
        if let genres = game.genreList {
            genres.forEach { genre in
                genreCount += 1
                if genreCount == genres.count {
                    game.genres += genre
                } else {
                    game.genres += "\(genre), "
                }
            }
        }

        if let released = game.released, released != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let date = dateFormatter.date(from: released)
            dateFormatter.dateFormat = "MMMM d, yyyy"
            game.firstRelease = dateFormatter.string(from: date!)
        }

        let rating = game.rating
        game.theRating = String(format: "%.1f", rating!)

        gameName.text = game.name
        gameImage.image = game.image
        gameGenre.text = game.genres
        gameRating.text = game.theRating
        gameReleaseDate.text = game.firstRelease
    }

    func cancelDownload() {
        viewModel?.cancelOperation()
    }
    
    deinit {
        cancelDownload()
    }
}

extension GameTableViewCell: GameCellViewModelDelegate {
    func fetchDidFinish(at indexPath: IndexPath, game: Game) {
        DispatchQueue.main.async {
            game.isDownloading = false
            self.updateImageDelegate?.updateImage()
            guard !self.tableView.isHidden && self.tableView.window != nil, self.tableView.cellForRow(at: indexPath) != nil else {
                game.shouldReload = true
                return
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
