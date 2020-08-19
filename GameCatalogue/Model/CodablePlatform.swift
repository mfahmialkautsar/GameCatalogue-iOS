//
//  CodablePlatform.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

struct CodablePlatform: Codable {
    let slug: String?

    enum CodingKeys: String, CodingKey {
        case slug
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.slug) {
            slug = try container.decode(String?.self, forKey: .slug)
        } else {
            slug = nil
        }
    }
}
