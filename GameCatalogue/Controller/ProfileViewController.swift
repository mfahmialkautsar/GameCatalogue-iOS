//
//  ProfileViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 28/07/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

protocol UpdateProfileDelegate {
    func update()
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileTitle: UILabel!
    @IBOutlet weak var profileAbout: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true

        Profile.synchronize()
        profileName.text = Profile.name
        profileTitle.text = Profile.title
        profileAbout.text = Profile.about
        profileImage.image = UIImage(data: Profile.image)

        profileName.accessibilityIdentifier = "Name"
        profileTitle.accessibilityIdentifier = "Title"
        profileAbout.accessibilityIdentifier = "About"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Game Catalogue"
    }

    @objc private func imageTapped(gesture: UIGestureRecognizer) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewScene") as? ImageViewController
        controller?.image = profileImage.image

        if (gesture.view as? UIImageView) != nil, let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func editProfile(_ sender: Any) {
        let editProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewScene") as? EditProfileViewController
        editProfileViewController?.updateDelegate = self
        editProfileViewController?.navItem = navigationItem
        if let editProfileViewController = editProfileViewController {
            navigationController?.pushViewController(editProfileViewController, animated: true)
        }
    }
}

extension ProfileViewController: UpdateProfileDelegate {
    func update() {
        Profile.synchronize()
        profileName.text = Profile.name
        profileTitle.text = Profile.title
        profileAbout.text = Profile.about
        profileImage.image = UIImage(data: Profile.image)
    }
}
