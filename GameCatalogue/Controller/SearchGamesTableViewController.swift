//
//  SearchGamesTableViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 29/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class SearchGamesTableViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchGameTableView: UITableView!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!
    @IBOutlet weak var notFoundLabel: UILabel!
    
    private var viewModel: SearchGamesViewModel!
    private var tableOffset: CGPoint?
    private var shouldReloadTable = false
    private var isRefreshing = false
    private var navBarBackground: UIImage?
    private var navBarShadow: UIImage?
    private var navBarTint: UIColor?
    
    private let refreshControl = UIRefreshControl()
    private let imageOperation = ImageOperation(queueName: "operation.searchGames")

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarTint = navigationController?.navigationBar.tintColor
        navBarBackground = navigationController?.navigationBar.backgroundImage(for: .default)
        navBarShadow = navigationController?.navigationBar.shadowImage

        notFoundLabel.isHidden = true
        searchGameTableView.isHidden = true
        loadBar.isHidden = true
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchGameTableView.dataSource = self
        searchGameTableView.delegate = self
        searchGameTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "GameCell")
        viewModel = SearchGamesViewModel(delegate: self)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.setBackgroundImage(navBarBackground, for: .default)
        navigationController?.navigationBar.shadowImage = navBarShadow
        navigationController?.navigationBar.tintColor = navBarTint
        navigationItem.title = "Search Game"
        if isRefreshing {
            refreshControl.beginRefreshing()
            if let tableOffset = tableOffset {
                searchGameTableView.contentOffset = tableOffset
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if self.shouldReloadTable {
                self.shouldReloadTable = false
                self.fetchDidComplete()
            }
            for index in 0 ..< self.viewModel.count {
                if self.viewModel.game(at: index).shouldReload {
                    self.viewModel.game(at: index).shouldReload = false
                    self.searchGameTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isRefreshing {
            tableOffset = searchGameTableView.contentOffset
            refreshControl.endRefreshing()
        }
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { self.searchGameTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0) })
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: CATransaction.animationDuration(), animations: { self.searchGameTableView.contentInset = .zero })
    }

    @objc fileprivate func refreshData() {
        DispatchQueue.main.async {
            self.viewModel.isLoading = false
            self.isRefreshing = true
            guard !self.viewModel.isLoading else { return }
            self.loadBar.isHidden = true
            self.loadBar.stopAnimating()
            for index in 0 ..< self.viewModel.count {
                let cell = self.searchGameTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GameTableViewCell
                cell?.cancelDownload()
            }
            self.viewModel.fetchSearchGames(searchText: self.viewModel.keyword, refresh: self.isRefreshing)
        }
    }

    deinit {
        viewModel.cancelTask()
        isRefreshing = true
        for index in 0 ..< viewModel.count {
            let cell = searchGameTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GameTableViewCell
            cell?.cancelDownload()
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchGamesTableViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchGameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell
        let game = viewModel.game(at: indexPath.row)

        cell?.tableView = tableView
        cell?.configure(with: game, indexPath: indexPath, operation: imageOperation, loadCell: !isRefreshing)
        
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.shouldLoadMore && indexPath.row == viewModel.count - 1 {
            loadBar.isHidden = false
            loadBar.startAnimating()
            viewModel.fetchSearchGames(searchText: self.viewModel.keyword)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailView", bundle: nil)
        let game = viewModel.game(at: indexPath.row)

        detail.game = game
        detail.navItem = navigationItem

        let cell = tableView.cellForRow(at: indexPath) as? GameTableViewCell
        cell?.updateImageDelegate = detail

        tableView.deselectRow(at: indexPath, animated: false)

        if game.state == .failed {
            game.image = #imageLiteral(resourceName: "image_placeholder")
            game.state = .new
            cell?.configure(with: game, indexPath: indexPath, operation: imageOperation, loadCell: !isRefreshing)
        }

        navigationController?.pushViewController(detail, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        notFoundLabel.isHidden = true
        viewModel.keyword = searchText
        loadBar.startAnimating()
        loadBar.isHidden = false
        viewModel.search.fire()

        if !searchText.isEmpty {
            guard !refreshControl.isDescendant(of: searchGameTableView) || searchGameTableView.refreshControl == nil else { return }

            if #available(iOS 10.0, *) {
                searchGameTableView.refreshControl = refreshControl
            } else {
                searchGameTableView.addSubview(refreshControl)
            }

            refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        } else {
            if #available(iOS 10.0, *) {
                searchGameTableView.refreshControl = nil
            } else {
                refreshControl.removeFromSuperview()
            }
        }
    }
}

extension SearchGamesTableViewController: SearchGamesViewModelDelegate {
    func fetchDidComplete() {
        searchGameTableView.isHidden = false
        isRefreshing = false
        loadBar.isHidden = true
        loadBar.stopAnimating()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
        guard searchGameTableView.window != nil else {
            shouldReloadTable = true
            return
        }
        searchGameTableView.reloadData()

        if viewModel.keyword.isEmpty {
            searchGameTableView.isHidden = true
        }

        if viewModel.count == 0 && !viewModel.keyword.isEmpty {
            searchGameTableView.isHidden = true
            notFoundLabel.text = "\"\(viewModel.keyword)\" is not found."
            notFoundLabel.isHidden = false
            return
        }
    }

    func fetchDidFail(with cause: (code: Int, description: String)) {
        guard cause.code != -999 else { return }
        searchGameTableView.isHidden = false
        isRefreshing = false
        loadBar.isHidden = true
        loadBar.stopAnimating()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }

        if cause.code == 404 && viewModel.count == 0 && viewModel.keyword.isEmpty {
            searchGameTableView.isHidden = true
            notFoundLabel.text = "\"\(viewModel.keyword)\" is not found."
            notFoundLabel.isHidden = false
        }

        showNetworkAlert(response: cause)
    }
}
