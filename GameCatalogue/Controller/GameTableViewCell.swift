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
    @IBOutlet weak var gameReleaseDate: UILabel! // it's not used, in case wanna change to use this rather than platforms
    @IBOutlet weak var loadBar: UIActivityIndicatorView!
    @IBOutlet weak var platforms: UIStackView!

    private var viewModel: GameCellViewModel!
    private var tableView: UITableView!
    var updateImageDelegate: UpdateDetailImageDelegate?

    func configure(with game: Game?, tableView: UITableView?, indexPath: IndexPath, operation: ImageOperation, loadCell: Bool) {
        if let game = game {
            viewModel = GameCellViewModel(delegate: self, game: game, indexPath: indexPath, operation: operation)

            self.tableView = tableView

            setView(game: game)

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
        platforms.addLogo(game: game, maxLogo: 6)
    }

    func cancelDownload() {
        viewModel.cancelOperation()
    }

    func imageDownloaded(indexPath: IndexPath, game: Game) {
        DispatchQueue.main.async {
            game.isDownloading = false
            self.updateImageDelegate?.updateImage()
            guard !self.tableView.isHidden && self.tableView.window != nil else {
                game.shouldReload = true
                return
            }
            guard self.tableView.cellForRow(at: indexPath) != nil else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension GameTableViewCell: GameCellViewModelDelegate {
    func fetchDidFinish(at indexPath: IndexPath, game: Game) {
        imageDownloaded(indexPath: indexPath, game: game)
    }
}
