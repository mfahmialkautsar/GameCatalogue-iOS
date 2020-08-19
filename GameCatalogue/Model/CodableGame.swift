//
//  CodableGame.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

struct CodableGame: Codable {
    let id: Int
    let name: String
    var imagePath: String?
    var released: String?
    var rating: Double?

    var description: String?
    var developers: [CodableDevelopers]?

    var genres: [CodableGenres]?
    var parentPlatforms: [CodableParentPlatforms]?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
        case imagePath = "background_image"
        case released
        case rating
        case genres
        case parentPlatforms = "parent_platforms"
        case description
        case developers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)

        for key in CodingKeys.allCases {
            if container.contains(key) {
                switch key {
                case .id:
                    break
                case .name:
                    break
                case .imagePath:
                    imagePath = try container.decode(String?.self, forKey: .imagePath)
                case .released:
                    released = try container.decode(String?.self, forKey: .released)
                case .rating:
                    rating = try container.decode(Double?.self, forKey: .rating)
                case .genres:
                    genres = try container.decode([CodableGenres]?.self, forKey: .genres)
                case .parentPlatforms:
                    parentPlatforms = try container.decode([CodableParentPlatforms]?.self, forKey: .parentPlatforms)
                case .description:
                    description = try container.decode(String?.self, forKey: .description)
                case .developers:
                    developers = try container.decode([CodableDevelopers]?.self, forKey: .developers)
                }
            } else {
                switch key {
                case .id:
                    break
                case .name:
                    break
                case .imagePath:
                    imagePath = nil
                case .released:
                    released = nil
                case .rating:
                    rating = nil
                case .genres:
                    genres = nil
                case .parentPlatforms:
                    parentPlatforms = nil
                case .description:
                    description = nil
                case .developers:
                    developers = nil
                }
            }
        }
    }
}
