//
//  Profile.swift
//  GameCatalogue
//
//  Created by Jamal on 26/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

struct Profile {
    static let firstLaunchKey = "first"
    static let nameKey = "name"
    static let titleKey = "title"
    static let aboutKey = "about"
    static let imageKey = "image"

    static var first: Bool {
        get {
            return UserDefaults.standard.bool(forKey: firstLaunchKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: firstLaunchKey)
        }
    }

    static var name: String {
        get {
            return UserDefaults.standard.string(forKey: nameKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }

    static var title: String {
        get {
            return UserDefaults.standard.string(forKey: titleKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: titleKey)
        }
    }

    static var about: String {
        get {
            return UserDefaults.standard.string(forKey: aboutKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: aboutKey)
        }
    }

    static var image: Data {
        get {
            return UserDefaults.standard.data(forKey: imageKey) ?? imageToData("person")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: imageKey)
        }
    }

    static func synchronize() {
        UserDefaults.standard.synchronize()
    }

    static func saveProfile(name: String, title: String, about: String, image: UIImage) {
        self.name = name
        self.title = title
        self.about = about
        self.image = image.jpegData(compressionQuality: 1)!
    }

    static func addDummyProfile() {
        if !first {
            saveProfile(name: "FAHMI AL", title: "Junior Developer", about: "Stay safe, guys.", image: #imageLiteral(resourceName: "person"))
            first = true
        }
    }
}

func imageToData(_ title: String) -> Data {
    if let img = UIImage(named: title) {
        return img.jpegData(compressionQuality: 1)!
    }
    return #imageLiteral(resourceName: "broken_image").jpegData(compressionQuality: 1)!
}
