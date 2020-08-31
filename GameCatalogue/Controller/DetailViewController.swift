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

protocol FavoriteDelegate {
    func didFavorite()
}

class DetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
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
    @IBOutlet weak var favoriteButton: UIButton!

    var navItem: UINavigationItem?
    var controller: ImageViewController?
    var game: Game?
    var favoriteDelegate: FavoriteDelegate?
    private var viewModel: DetailViewModel?
    private var favImage = "heart"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .black

        imageLoadBar.startAnimating()
        descriptionLoadBar.isHidden = false
        descriptionLoadBar.startAnimating()
        developersLoadBar.isHidden = false
        developersLoadBar.startAnimating()
        navItem?.title = ""

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

        gameImage.addGestureRecognizer(tapGesture)
        gameImage.isUserInteractionEnabled = true

        viewModel = DetailViewModel(delegate: self)

        guard let result = game else { return }
        if let viewModel = viewModel, viewModel.isFavorited(id: result.id) {
            favImage = "heart.fill"
            favoriteButton.setImage(UIImage(systemName: favImage), for: .normal)
        } else {
            favImage = "heart"
            favoriteButton.setImage(UIImage(systemName: favImage), for: .normal)
        }

        if let detail = result.detail {
            fetchDidComplete(response: detail)
            imageLoadBar.isHidden = true
            imageLoadBar.stopAnimating()
        } else {
            onlineFetch(result: result)
        }

        updateImage()
        gameName.text = result.name
        gameGenres.text = result.genres == "" ? "Unknown Genre" : result.genres
        gameReleaseDate.text = result.firstRelease == "" ? "Unknown Release Date" : result.firstRelease
        gameRating.text = result.theRating == "0.0" ? "No Rating" : result.theRating + "/10"
        gamePlatforms.addLogo(game: result, maxLogo: 10, width: 25, height: 25, marginLeft: 10)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true

        let navbarHeight = (navigationController?.navigationBar.frame.height ?? 0)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if let scrollView = scrollView {
            var bottom: CGFloat = 0
            if view.safeAreaInsets.bottom > 0 {
                bottom = 34
            }
            NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottom).isActive = true
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: -navbarHeight).isActive = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func onlineFetch(result: Game) {
        if let detail = result.detail {
            fetchDidComplete(response: detail)
        } else {
            gameDescription.text = "Loading Description..."
            gameDevelopers.text = "Loading Developers..."
            viewModel?.fetchDetail(id: result.id)
        }
    }

    func loadImageController(image: UIImage) {
        controller?.loadImage(image: image, isLoaded: !imageLoadBar.isAnimating)
    }

    @objc private func imageTapped(gesture: UIGestureRecognizer) {
        DispatchQueue.main.async {
            self.controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewScene") as? ImageViewController

            if (gesture.view as? UIImageView) != nil {
                self.present(self.controller!, animated: true, completion: nil)
                self.loadImageController(image: self.game!.image!)
            }
        }
    }

    @IBAction func saveToFavorite(_ sender: Any) {
        if let game = game {
            guard !imageLoadBar.isAnimating && !descriptionLoadBar.isAnimating && !developersLoadBar.isAnimating && game.state == .downloaded || favImage == "heart.fill" else {
                showAlert(title: "Can't do it right now", message: "Please wait until all of the components are fully loaded.", action: "Okay")
                return
            }

            favoriteButton.isEnabled = false
            viewModel?.favorite(game: game) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.favoriteDelegate?.didFavorite()
                        self.favoriteButton.isEnabled = true
                        if self.favImage == "heart.fill" {
                            self.favImage = "heart"
                        } else {
                            self.favImage = "heart.fill"
                        }
                        self.favoriteButton.setImage(UIImage(systemName: self.favImage), for: .normal)
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        self.favoriteButton.isEnabled = true
                        self.showAlert(title: "Error \(error.reason.code)", message: error.reason.description, action: "Okay")
                    }
                }
            }
        }
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func fetchDidComplete(response: Detail) {
        if let game = game, game.detail == nil {
            game.detail = response
        }

        if let descText = gameDescription, let descriptionResponse = response.description {
            let formattedDesc = String(format: "<span style=\"text-align: justify; text-justify: inter-word; font-family: \(descText.font.familyName); font-size: \(descText.font.pointSize)\">%@</span>", descriptionResponse)
            if let descData = formattedDesc.data(using: .unicode), let attributedDesc = try? NSAttributedString(data: descData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                descText.attributedText = attributedDesc
            }
        } else {
            gameDevelopers.text = ""
        }

        descriptionLoadBar.isHidden = true
        descriptionLoadBar.stopAnimating()

        var developers = ""
        if let developerResponse = response.developers, !developerResponse.isEmpty {
            var devCount = 0
            developerResponse.forEach { dev in
                devCount += 1
                if devCount == developerResponse.count {
                    developers += dev
                } else {
                    developers += dev + ", "
                }
            }
        } else {
            developers = "Unknown Developers"
        }
        gameDevelopers.text = developers

        developersLoadBar.isHidden = true
        developersLoadBar.stopAnimating()
    }

    func fetchDidFail(cause: (code: Int, description: String)) {
        gameDescription.text = "ERROR"
        gameDevelopers.text = "ERROR"
        descriptionLoadBar.isHidden = true
        descriptionLoadBar.stopAnimating()
        developersLoadBar.isHidden = true
        developersLoadBar.stopAnimating()
        showNetworkAlert(response: cause)
    }
}

extension DetailViewController: UpdateDetailImageDelegate {
    func updateImage() {
        DispatchQueue.main.async {
            if let result = self.game {
                guard self.isViewLoaded else { return }
                self.gameImage.image = result.image
                if let gameImage = self.gameImage {
                    gameImage.translatesAutoresizingMaskIntoConstraints = false
                    let height = gameImage.image?.size.height
                    let width = gameImage.image?.size.width

                    if let height = height, let width = width {
                        let imageConstraint = NSLayoutConstraint(item: gameImage, attribute: .height, relatedBy: .equal, toItem: gameImage, attribute: .width, multiplier: height / width, constant: 0)
                        NSLayoutConstraint.activate([imageConstraint])
                    }
                }
                if result.state == .downloaded || result.state == .failed {
                    self.imageLoadBar.isHidden = true
                    self.imageLoadBar.stopAnimating()
                    if self.controller != nil {
                        self.loadImageController(image: result.image ?? #imageLiteral(resourceName: "image_placeholder"))
                    }
                }
            }
        }
    }
}
