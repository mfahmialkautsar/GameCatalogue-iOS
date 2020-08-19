//
//  UIStackViewEntension.swift
//  GameCatalogue
//
//  Created by Jamal on 19/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

extension UIStackView {

    func addLogo(game: Game, maxLogo: Int, width: CGFloat = 20, height: CGFloat = 20, marginLeft: CGFloat = 6) {
        let platformList: Set<String> = [
            "pc", "playstation", "xbox", "ios", "android", "mac", "linux", "nintendo", "web",
        ]
        
        var platformLogo = [String]()

        game.parentPlatformNames?.forEach { platform in
            let platform = platform.lowercased()

            platformList.forEach { platformName in
                var logo = platformName.lowercased()

                if platform.contains(logo) {
                    if logo == "pc" {
                        logo = "windows"
                    }

                    guard !platformLogo.contains(logo) else { return }
                    platformLogo.append(logo)
                }
            }
        }

        if let parentPlatforms = game.parentPlatformNames, !parentPlatforms.subtracting(platformList).isEmpty {
            platformLogo.append("more")
        }

        self.subviews.forEach({ $0.removeFromSuperview() })
        var logoBefore: UIImageView?
        var logoCount = 1

        platformLogo.forEach { logo in
            var logo = logo
            if platformLogo.count > logoCount && logoCount >= maxLogo {
                logo = "more"
            }

            guard logoCount <= maxLogo else { return }
            let logoImage = UIImageView(image: UIImage(named: logo))
            self.addSubview(logoImage)
            logoCount += 1

            let widthConstraint = NSLayoutConstraint(item: logoImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
            let heightConstraint = NSLayoutConstraint(item: logoImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
            let verticalConstraint = NSLayoutConstraint(item: logoImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            
            var constraint = [
                widthConstraint,
                heightConstraint,
                verticalConstraint
            ]

            if logoBefore != nil {
                constraint.append(logoImage.leadingAnchor.constraint(equalTo: logoBefore!.trailingAnchor, constant: marginLeft))
            }

            logoImage.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(constraint)
            logoBefore = logoImage
        }
    }
}
