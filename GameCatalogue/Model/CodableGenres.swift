//
//  CodableGenres.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

struct CodableGenres: Codable {
    let name: String?

    enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.name) {
            name = try container.decode(String?.self, forKey: .name)
        } else {
            name = nil
        }
    }
}
