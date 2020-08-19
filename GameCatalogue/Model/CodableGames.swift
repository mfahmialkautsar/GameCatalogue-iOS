//
//  CodableGames.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

struct CodableGames: Codable {
    let count: Int
    let next: String?
    let previous: String?

    let games: [CodableGame]

    enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case games = "results"
    }
}
