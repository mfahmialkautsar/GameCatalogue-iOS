//
//  GameProvider.swift
//  GameCatalogue
//
//  Created by Jamal on 26/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import CoreData
import UIKit

class GameProvider {
    static let sharedInstance = GameProvider()
    func getFavorite() -> [Game] {
        favoritedGames
    }

    private var favoritedGames = [Game]()
    private var shouldReFetch = true

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Games")
        container.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("Unresolved Error \(error!)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil

        return container
    }()

    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.undoManager = nil
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }

    func getAllGames(completion: @escaping (Result<[Game], ErrorResponse>) -> Void) {
        guard shouldReFetch else {
            completion(Result.success(favoritedGames))
            return
        }
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorite")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games = [Game]()
                results.forEach { result in
                    if let id = result.value(forKey: "id") as? Int32,
                        let name = result.value(forKey: "name") as? String {
                        let game = Game(id: id,
                                        name: name,
                                        image: result.value(forKey: "image") as? Data,
                                        genreList: result.value(forKey: "genres") as? [String],
                                        released: result.value(forKey: "released") as? String,
                                        rating: result.value(forKey: "rating") as? Double,
                                        parentPlatformNames: result.value(forKey: "platforms") as? Set<String>,
                                        desc: result.value(forKey: "desc") as? String,
                                        developers: result.value(forKey: "developers") as? [String]
                        )
                        games.append(game)
                    }
                }
                self.favoritedGames = games
                self.shouldReFetch = false
                completion(Result.success(games))
            } catch let error as NSError {
                completion(Result.failure(ErrorResponse.error(error.code, error.localizedDescription)))
            }
        }
    }

    func addFavorite(game: Game, completion: @escaping (Result<Game?, ErrorResponse>) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            if let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: taskContext) {
                let gameEntity = NSManagedObject(entity: entity, insertInto: taskContext)
                gameEntity.setValue(Int32(game.id), forKey: "id")
                gameEntity.setValue(game.name, forKey: "name")
                gameEntity.setValue(game.image?.jpegData(compressionQuality: 1), forKey: "image")
                gameEntity.setValue(game.genreList, forKey: "genres")
                gameEntity.setValue(game.released, forKey: "released")
                gameEntity.setValue(game.rating, forKey: "rating")
                gameEntity.setValue(game.parentPlatformNames, forKey: "platforms")
                gameEntity.setValue(game.detail?.description, forKey: "desc")
                gameEntity.setValue(game.detail?.developers, forKey: "developers")

                do {
                    try taskContext.save()
                    self.shouldReFetch = true
                    completion(Result.success(nil))
                    self.getAllGames(completion: { _ in })
                } catch let error as NSError {
                    completion(Result.failure(ErrorResponse.error(error.code, error.localizedDescription)))
                }
            }
        }
    }

    func deleteFavorite(id: Int, completion: @escaping (Result<Game?, ErrorResponse>) -> Void) {
        let taskRequest = newTaskContext()
        taskRequest.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "id == \(id)")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDeleteResult = try? taskRequest.execute(batchDeleteRequest) as? NSBatchDeleteResult, batchDeleteResult.result != nil {
                self.shouldReFetch = true
                completion(Result.success(nil))
                self.getAllGames(completion: { _ in })
            }
        }
    }
}
