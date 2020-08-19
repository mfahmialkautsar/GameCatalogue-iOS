//
//  DetailViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 29/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

protocol UpdateDetailImageDelegate {
    func updateImage()
}

class DetailViewController: UIViewController {
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var gameDescription: UILabel!
    @IBOutlet weak var imageLoadBar: UIActivityIndicatorView!
    @IBOutlet weak var gamePlatforms: UIStackView!
    @IBOutlet weak var gameGenres: UILabel!
    @IBOutlet weak var gameRating: UILabel!
    @IBOutlet weak var gameReleaseDate: UILabel!
    @IBOutlet weak var gameDevelopers: UILabel!
    @IBOutlet weak var developersLoadBar: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLoadBar: UIActivityIndicatorView!
    @IBOutlet weak var line1: UIView!

    var controller: ImageViewController?
    var game: Game?
    private var viewModel: DetailViewModel?

    private let alertManager = AlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        imageLoadBar.startAnimating()
        descriptionLoadBar.isHidden = false
        descriptionLoadBar.startAnimating()
        developersLoadBar.isHidden = false
        developersLoadBar.startAnimating()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

        gameImage.addGestureRecognizer(tapGesture)
        gameImage.isUserInteractionEnabled = true

        viewModel = DetailViewModel(delegate: self)

        if let result = game {
            if let detail = result.detail {
                fetchDidComplete(response: detail)
            } else {
                viewModel?.cancelTask()
                gameDescription.text = "Loading Description..."
                gameDevelopers.text = "Loading Developers..."
                viewModel?.fetchDetail(id: result.id)
            }

            updateImage()
            gameName.text = result.name
            gameGenres.text = result.genres == "" ? "Unknown Genre" : result.genres
            gameReleaseDate.text = result.firstRelease == "" ? "Unknown Release Date" : result.firstRelease
            gameRating.text = result.theRating == "0.0" ? "No Rating" : result.theRating + "/10"
            gamePlatforms.addLogo(game: result, maxLogo: 10, width: 25, height: 25, marginLeft: 10)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func loadImageController(image: UIImage) {
        controller?.loadImage(image: image, isLoaded: !imageLoadBar.isAnimating)
    }

    @objc private func imageTapped(gesture: UIGestureRecognizer) {
        DispatchQueue.main.async {
            self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewScene") as? ImageViewController

            if (gesture.view as? UIImageView) != nil {
                self.present(self.controller!, animated: true, completion: nil)
                self.loadImageController(image: self.game!.image)
            }
        }
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func fetchDidComplete(response: Detail) {
        if let game = game, game.detail == nil {
            game.detail = response
        }

        if let descText = gameDescription {
            let formattedDesc = String(format: "<span style=\"text-align: justify; text-justify: inter-word; font-family: \(descText.font.familyName); font-size: \(descText.font.pointSize)\">%@</span>", response.description)
            if let descData = formattedDesc.data(using: .unicode), let attributedDesc = try? NSAttributedString(data: descData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                descText.attributedText = attributedDesc
            }
        } else {
            gameDevelopers.text = ""
        }

        descriptionLoadBar.isHidden = true
        descriptionLoadBar.stopAnimating()

        gameDevelopers.text = response.developers

        developersLoadBar.isHidden = true
        developersLoadBar.stopAnimating()
    }

    func fetchDidFail() {
        gameDescription.text = "ERROR"
        gameDevelopers.text = "ERROR"
        descriptionLoadBar.isHidden = true
        descriptionLoadBar.stopAnimating()
        developersLoadBar.isHidden = true
        developersLoadBar.stopAnimating()
    }
}

extension DetailViewController: UpdateDetailImageDelegate {
    func updateImage() {
        DispatchQueue.main.async {
            if let result = self.game {
                guard self.isViewLoaded else { return }
                self.gameImage.image = result.image
                if result.state == .downloaded || result.state == .failed {
                    self.imageLoadBar.isHidden = true
                    self.imageLoadBar.stopAnimating()
                    if self.controller != nil {
                        self.loadImageController(image: result.image)
                    }
                }
            }
        }
    }
}
