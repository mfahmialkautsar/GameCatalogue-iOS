//
//  TopProfileViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class TopProfileViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    @objc private func imageTapped(gesture: UIGestureRecognizer) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewScene") as? ImageViewController
        controller?.image = #imageLiteral(resourceName: "profile_photo_full")

        if (gesture.view as? UIImageView) != nil, let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
}
