//
//  AlertManager.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class AlertManager {
    private func didError(errorName: String) -> (alert: UIAlertController, animated: Bool) {
        let alert = UIAlertController(title: "\(errorName)!", message: "Check your internet connection and pull down the page to refresh.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        return (alert, true)
    }

    func show(view: UIViewController, errorCode: Int) {
        guard errorCode != -999 && errorCode != 404 else { return }
        guard let _ = view.view.window else { return }
        guard view.presentedViewController == nil else { return }
        let network = AlertManager().didError(errorName: "Network Error")
        view.present(network.alert, animated: network.animated)
    }
}

extension UIViewController {
    
}
