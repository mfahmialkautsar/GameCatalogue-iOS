//
//  ImageViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var loadBar: UIActivityIndicatorView!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = image {
            photoImage.image = image
        }
        loadBar.isHidden = true
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoImage
    }

    func loadImage(image: UIImage, isLoaded: Bool) {
        guard isViewLoaded else { return }
        loadBar.startAnimating()
        loadBar.isHidden = false
        photoImage.image = image
        if isLoaded {
            loadBar.isHidden = true
            loadBar.stopAnimating()
        }
    }
}
