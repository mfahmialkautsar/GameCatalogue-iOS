//
//  GamesTableViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class GamesTableViewController: UIViewController {
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    private var viewModel: GamesViewModel!
    private var tableOffset: CGPoint?
    private var shouldReloadTable = false
    private var isRefreshing = false
    private var imageOperation = ImageOperation(queueName: "operation.games")

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        gameTableView.isHidden = true
        gameTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "GameCell")

        loadBar.startAnimating()
        viewModel = GamesViewModel(delegate: self)
        viewModel.fetchGames()

        if #available(iOS 10.0, *) {
            gameTableView.refreshControl = refreshControl
        } else {
            gameTableView.addSubview(refreshControl)
        }

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isRefreshing {
            refreshControl.beginRefreshing()
            if let tableOffset = tableOffset {
                gameTableView.contentOffset = tableOffset
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
                    self.gameTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isRefreshing {
            tableOffset = gameTableView.contentOffset
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
                let cell = self.gameTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GameTableViewCell
                cell?.cancelDownload()
            }
            self.viewModel.fetchGames(refresh: self.isRefreshing)
        }
    }
}

extension GamesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = gameTableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameTableViewCell

        cell?.configure(with: viewModel.game(at: indexPath.row), tableView: tableView, indexPath: indexPath, operation: imageOperation, loadCell: !isRefreshing)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.shouldLoadMore && indexPath.row == viewModel.count - 1 {
            guard !viewModel.isLoading else { return }
            DispatchQueue.main.async {
                self.loadBar.isHidden = false
                self.loadBar.startAnimating()
                self.viewModel.fetchGames()
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
}

extension GamesTableViewController: GamesViewModelDelegate {
    func fetchDidComplete() {
        gameTableView.isHidden = false
        isRefreshing = false
        loadBar.isHidden = true
        loadBar.stopAnimating()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
        guard gameTableView.window != nil else {
            shouldReloadTable = true
            return
        }
        gameTableView.reloadData()
    }

    func fetchDidFail(with cause: Any) {
        guard let cause = cause as? Int, cause != -999 else { return }

        gameTableView.isHidden = false
        isRefreshing = false
        loadBar.isHidden = true
        loadBar.stopAnimating()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }

        AlertManager().show(view: self, errorCode: cause)
    }
}
