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
    var name: String?
    var imagePath: String?
    var genreList: [String]?
    var released: String?
    var rating: Double?
    var parentPlatformNames: Set<String>?

    var detail: Detail?
    var image: UIImage? = #imageLiteral(resourceName: "image_placeholder")
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
    
    init(id: Int32, name: String, image: Data?, genreList: [String]?, released: String?, rating: Double?, parentPlatformNames: Set<String>?, desc: String?, developers: [String]?) {
        self.id = Int(id)
        self.name = name
        self.image = UIImage(data: image ?? #imageLiteral(resourceName: "image_placeholder").jpegData(compressionQuality: 1)!)
        self.genreList = genreList
        self.released = released
        self.rating = rating
        self.parentPlatformNames = parentPlatformNames
        self.detail = Detail(description: desc, developers: developers)
    }
    
    init(id: Int32) {
        self.id = Int(id)
    }
}
