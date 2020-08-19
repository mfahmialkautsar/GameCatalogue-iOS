//
//  Game.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class Game {
    let id: Int
    let name: String
    let imagePath: String?
    let genreList: [String]?
    let released: String?
    let rating: Double?
    let parentPlatformNames: Set<String>?

    var detail: Detail?
    var image: UIImage = #imageLiteral(resourceName: "image_placeholder")
    var genres: String = ""
    var firstRelease: String = ""
    var theRating: String = ""
    var state: DownloadState = .new
    var shouldReload = false
    var isDownloading = false

    init(id: Int, name: String, imagePath: String?, genreList: [String]?, released: String?, rating: Double?, parentPlatformNames: Set<String>?) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.genreList = genreList
        self.released = released
        self.rating = rating
        self.parentPlatformNames = parentPlatformNames
    }
}
