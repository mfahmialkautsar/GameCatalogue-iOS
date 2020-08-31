//
//  Client.swift
//  GameCatalogue
//
//  Created by Jamal on 10/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

final class Client {
    private lazy var baseURL: URL = {
        URL(string: "https://api.rawg.io/api/games")!
    }()

    private lazy var apiKey: (key: String, value: String) = (key: "key", value: ProcessInfo.processInfo.environment["API_KEY"] ?? "")

    var mainTask: URLSessionDataTask?
    var detailTask: URLSessionDataTask?
    var imageTask: URLSessionDataTask?

    func session(timeOut: TimeInterval = 60) -> URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = timeOut
        config.timeoutIntervalForResource = timeOut
        return URLSession(configuration: config)
    }

    func fetchGames(queueLabel: String, queryItems: [(key: String, value: String)] = [], completion: @escaping (Result<CodableGames, ErrorResponse>) -> Void) {
        let queue = DispatchQueue(label: queueLabel, qos: .userInteractive)
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let queries = [apiKey] + queryItems
        var qItems = [URLQueryItem]()

        queries.forEach { arg in
            let (key, value) = arg
            qItems.append(URLQueryItem(name: key, value: value))
        }

        components?.queryItems = qItems

        let urlRequest = URLRequest(url: (components?.url)!)

        queue.async {
            self.mainTask = self.session().dataTask(with: urlRequest) { data, response, error in

                if let error = error as NSError? {
                    switch error.code {
                    case -999:
                        return
                    default:
                        completion(Result.failure(ErrorResponse.error(error.code, error.localizedDescription)))
                        return
                    }
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(Result.failure(ErrorResponse.error(0, "Response Error")))
                    return
                }

                switch response.statusCode {
                case 200 ... 299:
                    guard let data = data, let games = try? JSONDecoder().decode(CodableGames.self, from: data) else {
                        completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                        return
                    }

                    completion(Result.success(games))
                default:
                    completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                }
            }

            self.mainTask?.resume()
        }
    }

    func fetchDetail(queueLabel: String, id: Int, completion: @escaping (Result<CodableGame, ErrorResponse>) -> Void) {
        let queue = DispatchQueue(label: queueLabel, qos: .userInteractive)

        baseURL.appendPathComponent(String(id))
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let queryItem = URLQueryItem(name: apiKey.key, value: apiKey.value)
        components?.queryItems = [queryItem]

        let urlRequest = URLRequest(url: (components?.url)!)

        queue.async {
            self.detailTask = self.session().dataTask(with: urlRequest) { data, response, error in

                if let error = error as NSError? {
                    switch error.code {
                    case -999:
                        return
                    default:
                        completion(Result.failure(ErrorResponse.error(error.code, error.localizedDescription)))
                        return
                    }
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(Result.failure(ErrorResponse.error(0, "Response Error")))
                    return
                }

                switch response.statusCode {
                case 200 ... 299:
                    guard let data = data, let detail = try? JSONDecoder().decode(CodableGame.self, from: data) else { completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                        return
                    }

                    completion(Result.success(detail))
                default:
                    completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                }
            }

            self.detailTask?.resume()
        }
    }

    func fetchImage(from url: URL, completion: @escaping (Result<Data, ErrorResponse>) -> Void) {
        let queue = DispatchQueue(label: "fetchImage", qos: .userInteractive)

        queue.async {
            self.imageTask = self.session(timeOut: 120).dataTask(with: url) { data, response, error in

                if let error = error as NSError? {
                    completion(Result.failure(ErrorResponse.error(error.code, error.localizedDescription)))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(Result.failure(ErrorResponse.error(0, "Response Error")))
                    return
                }

                switch response.statusCode {
                case 200 ... 299:
                    guard let data = data else {
                        completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                        return
                    }

                    completion(Result.success(data))
                default:
                    completion(Result.failure(ErrorResponse.error(response.statusCode, response.description)))
                }
            }

            self.imageTask?.resume()
        }
    }

    func cancelMainTask() {
        mainTask?.cancel()
    }

    func cancelDetailTask() {
        detailTask?.cancel()
    }

    func cancelImageTask() {
        imageTask?.cancel()
    }
}
