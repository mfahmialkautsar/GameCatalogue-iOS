//
//  FavoriteGamesViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class FavoriteGamesTableViewController: UIViewController {
    @IBOutlet weak var favoriteGameTableView: UITableView!
    @IBOutlet weak var notFoundLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    private var viewModel: FavoriteGamesViewModel!
    private var favoriteDelegate: FavoriteDelegate?
    private var navBarBackground: UIImage?
    private var navBarShadow: UIImage?
    private var navBarTint: UIColor?

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarTint = navigationController?.navigationBar.tintColor
        navBarBackground = navigationController?.navigationBar.backgroundImage(for: .default)
        navBarShadow = navigationController?.navigationBar.shadowImage
        
        let searchBarHeight = searchBar.frame.height
        favoriteGameTableView.contentOffset = CGPoint(x: 0, y: searchBarHeight)

        searchBar.delegate = self
        favoriteGameTableView.isHidden = true
        favoriteGameTableView.delegate = self
        favoriteGameTableView.dataSource = self
        favoriteGameTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "GameCell")

        viewModel = FavoriteGamesViewModel(delegate: self)
        loadBar.startAnimating()
        viewModel.getGames()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(navBarBackground, for: .default)
        navigationController?.navigationBar.shadowImage = navBarShadow
        navigationController?.navigationBar.tintColor = navBarTint
        navigationItem.title = "Favorite Games"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favoriteGameTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
        favoriteGameTableView.contentInset = .zero
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { self.favoriteGameTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0) })
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: { self.favoriteGameTableView.contentInset = .zero })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FavoriteGamesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoriteGameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell

        cell?.tableView = tableView
        cell?.configure(with: viewModel.game(at: indexPath.row), indexPath: indexPath, operation: nil, loadCell: nil)

        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailView", bundle: nil)
        let game = viewModel.game(at: indexPath.row)
        detail.game = game
        detail.navItem = navigationItem
        detail.favoriteDelegate = self
        tableView.deselectRow(at: indexPath, animated: false)
        navigationController?.pushViewController(detail, animated: true)
    }
}

extension FavoriteGamesTableViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        notFoundLabel.isHidden = true
        viewModel.keyword = searchText
        loadBar.startAnimating()
        loadBar.isHidden = false
        viewModel.search.fire()
    }
}

extension FavoriteGamesTableViewController: FavoriteGamesViewModelDelegate {
    func fetchDidComplete() {
        loadBar.isHidden = true
        loadBar.stopAnimating()
        favoriteGameTableView.reloadData()
        if viewModel.count > 0 {
            notFoundLabel.isHidden = true
            favoriteGameTableView.isHidden = false
        } else {
            if !viewModel.keyword.isEmpty {
                notFoundLabel.text = "\"\(viewModel.keyword)\" is not in favorite"
                favoriteGameTableView.isHidden = false
            } else {
                notFoundLabel.text = "You haven't added any game to favorite"
                favoriteGameTableView.isHidden = true
            }
            notFoundLabel.isHidden = false
        }
    }

    func fetchDidFail(with cause: (code: Int, description: String)) {
        showNetworkAlert(response: cause)
    }
}

extension FavoriteGamesTableViewController: FavoriteDelegate {
    func didFavorite() {
        guard isViewLoaded else { return }
        loadBar.startAnimating()
        viewModel.getGames()
    }
}
