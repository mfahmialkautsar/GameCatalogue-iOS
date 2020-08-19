//
//  CodableParentPlatforms.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import Foundation

struct CodableParentPlatforms: Codable {
    let platform: CodablePlatform?

    enum CodingKeys: String, CodingKey {
        case platform
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.platform) {
            platform = try container.decode(CodablePlatform?.self, forKey: .platform)
        } else {
            platform = nil
        }
    }
}
