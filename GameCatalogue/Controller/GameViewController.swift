//
//  GameViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var newReleaseView: UIView!

    private var navBarTint: UIColor?

    var firstTime = true
    override func viewDidLoad() {
        super.viewDidLoad()
        newReleaseView?.isHidden = true
        navBarTint = navigationController?.navigationBar.tintColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Game Catalogue"
        navigationController?.navigationBar.tintColor = navBarTint
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }

    @IBAction func switchViews(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            newReleaseView.isHidden = true
            popularView.isHidden = false
        case 1:
            if firstTime {
                firstTime = false
                let newGame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGamesTableViewScene")
                addChild(newGame)
                newReleaseView.addSubview(newGame.view)
                newGame.view.frame = newReleaseView.bounds
                newGame.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                newGame.didMove(toParent: self)
            }

            popularView.isHidden = true
            newReleaseView.isHidden = false
        default:
            return
        }
    }

    @IBAction func presentFavoriteView(_ sender: Any) {
        let favoriteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FavoriteViewScene")

        navigationController?.present(UINavigationController(rootViewController: favoriteViewController), animated: true, completion: nil)
    }

    @IBAction func presentSearchView(_ sender: Any) {
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewScene")

        navigationController?.present(UINavigationController(rootViewController: searchViewController), animated: true, completion: nil)
    }
}
