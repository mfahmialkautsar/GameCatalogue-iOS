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
    @IBOutlet weak var searchButton: UIButton!

    var firstTime = true
    override func viewDidLoad() {
        super.viewDidLoad()
        newReleaseView.isHidden = true
        navigationItem.title = "Game Catalogue"
        searchButton.addTarget(self, action: #selector(presentSearchView), for: .touchUpInside)
    }

    @IBAction func switchViews(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            newReleaseView.isHidden = true
            popularView.isHidden = false
        case 1:
            if firstTime {
                firstTime = false
                let newGame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewGameTableViewScene")
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

    @objc private func presentSearchView() {
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewScene")
        navigationController?.present(UINavigationController(rootViewController: searchViewController), animated: true, completion: nil)
    }
}
