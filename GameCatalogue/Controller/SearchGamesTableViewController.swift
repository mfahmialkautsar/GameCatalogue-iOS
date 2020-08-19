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
    private var refreshControl = UIRefreshControl()
    private var shouldReloadTable = false
    private var isRefreshing = false
    private var imageOperation = ImageOperation(queueName: "operation.searchGames")

    override func viewDidLoad() {
        super.viewDidLoad()

        notFoundLabel.isHidden = true
        searchGameTableView.isHidden = true
        loadBar.isHidden = true
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchGameTableView.dataSource = self
        searchGameTableView.delegate = self
        searchGameTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "GameCell")
        navigationItem.title = "Search Game"
        viewModel = SearchGamesViewModel(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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

    @objc fileprivate func refreshData() {
        DispatchQueue.main.async {
            self.viewModel.isLoading = false
            self.isRefreshing = true
            guard !self.viewModel.isLoading else { return }
            self.loadBar.isHidden = true
            self.loadBar.stopAnimating()
            self.viewModel.cancelTask()
            for index in 0 ..< self.viewModel.count {
                let cell = self.searchGameTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GameTableViewCell
                cell?.cancelDownload()
            }
            self.viewModel.fetchSearchGames(searchText: self.viewModel.keyword, refresh: self.isRefreshing)
        }
    }
    
    deinit {
        viewModel.cancelTask()
    }
}

extension SearchGamesTableViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchGameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell
        cell?.configure(with: viewModel.game(at: indexPath.row), tableView: tableView, indexPath: indexPath, operation: imageOperation, loadCell: !isRefreshing)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.shouldLoadMore && indexPath.row == viewModel.count - 1 {
            DispatchQueue.main.async {
                self.loadBar.isHidden = false
                self.loadBar.startAnimating()
                self.viewModel.fetchSearchGames(searchText: self.viewModel.keyword)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = DetailViewController(nibName: "DetailView", bundle: nil)
        let game = viewModel.game(at: indexPath.row)

        detail.game = game

        let cell = tableView.cellForRow(at: indexPath) as? GameTableViewCell
        cell?.updateImageDelegate = detail

        tableView.deselectRow(at: indexPath, animated: false)

        if game.state == .failed {
            game.image = #imageLiteral(resourceName: "image_placeholder")
            game.state = .new
            cell?.configure(with: game, tableView: tableView, indexPath: indexPath, operation: imageOperation, loadCell: !isRefreshing)
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
            notFoundLabel.text = "\"\(viewModel.keyword)\" not found."
            notFoundLabel.isHidden = false
            return
        }
    }

    func fetchDidFail(with cause: Any) {
        guard let cause = cause as? Int, cause != -999 else { return }
        searchGameTableView.isHidden = false
        isRefreshing = false
        loadBar.isHidden = true
        loadBar.stopAnimating()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }

        if cause == 404 && viewModel.count == 0 && viewModel.keyword.isEmpty {
            searchGameTableView.isHidden = true
            notFoundLabel.text = "\"\(viewModel.keyword)\" not found."
            notFoundLabel.isHidden = false
        }

        AlertManager().show(view: self, errorCode: cause)
    }
}
