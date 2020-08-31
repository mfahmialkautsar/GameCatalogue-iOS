//
//  UIViewControllerExtension.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, action: String) {
        guard let _ = view.window else { return }
        guard presentedViewController == nil else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))

        present(alert, animated: true)
    }

    func showNetworkAlert(response: (code: Int, description: String)) {
        guard response.code != -999 && response.code != 404 else { return }

        showAlert(title: "Error \(response.code)", message: response.description + "\nCheck your internet connection and refresh the page if needed!", action: "Okay")
    }
}
