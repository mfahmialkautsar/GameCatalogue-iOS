//
//  GameCellViewModel.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

protocol GameCellViewModelDelegate: class {
    func fetchDidFinish(at indexPath: IndexPath, game: Game)
}

final class GameCellViewModel {
    private weak var delegate: GameCellViewModelDelegate?
    private var game: Game
    private var indexPath: IndexPath
    private var imageOperation: ImageOperation
    private var client = Client()

    init(delegate: GameCellViewModelDelegate, game: Game, indexPath: IndexPath, operation: ImageOperation) {
        self.delegate = delegate
        self.game = game
        self.indexPath = indexPath
        imageOperation = operation
    }

    func fetchImage() {
        guard !game.isDownloading else { return }

        let imageDownloader = BlockOperation {
                guard let imagePath = self.game.imagePath, imagePath != "" else {
                    self.game.image = #imageLiteral(resourceName: "no_image")
                    self.game.state = .downloaded
                    self.delegate?.fetchDidFinish(at: self.indexPath, game: self.game)
                    return
                }

                self.client.fetchImage(from: URL(string: imagePath)!) { result in
                    switch result {
                    case let .success(response):
                        self.game.image = UIImage(data: response) ?? #imageLiteral(resourceName: "broken_image")
                        self.game.state = .downloaded
                        self.delegate?.fetchDidFinish(at: self.indexPath, game: self.game)
                    case .failure:
                        self.game.image = #imageLiteral(resourceName: "broken_image")
                        self.game.state = .failed
                        self.delegate?.fetchDidFinish(at: self.indexPath, game: self.game)
                    }
                }
        }
        imageDownloader.qualityOfService = .userInteractive

        game.isDownloading = true
        imageOperation.downloadQueue.addOperation(imageDownloader)
    }

    func cancelOperation() {
        imageOperation.downloadQueue.cancelAllOperations()
        client.cancelImageTask()
    }
}
