//
//  EditProfileViewController.swift
//  GameCatalogue
//
//  Created by Jamal on 25/08/20.
//  Copyright © 2020 Kementerian Agama RI. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var removePhotoButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var aboutField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    var updateDelegate: UpdateProfileDelegate?
    var navItem: UINavigationItem?
    private let imagePicker = UIImagePickerController()
    private var keyboardSize: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary

        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        navItem?.title = "Profile"
        navigationItem.title = "Edit Profile"

        Profile.synchronize()
        nameField.text = Profile.name
        titleField.text = Profile.title
        aboutField.text = Profile.about
        profileImage.image = UIImage(data: Profile.image)
        checkIfTextEmpty()
        
        if Profile.image == #imageLiteral(resourceName: "person").jpegData(compressionQuality: 1) {
            removePhotoButton.isEnabled = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    @IBAction func nameFieldChanged(_ sender: Any) {
        checkIfTextEmpty()
    }

    @IBAction func titleFieldChanged(_ sender: Any) {
        checkIfTextEmpty()
    }

    @IBAction func aboutFieldChanged(_ sender: Any) {
        checkIfTextEmpty()
    }

    @IBAction func choosePhoto(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func removePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Photo", message: "Are you sure?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { _ in
            DispatchQueue.main.async {
                self.profileImage.image = #imageLiteral(resourceName: "person")
                self.removePhotoButton.isEnabled = false
            }
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        if let name = nameField.text, let title = titleField.text, let about = aboutField.text, let image = profileImage.image {
            Profile.saveProfile(name: name, title: title, about: about, image: image)
            updateDelegate?.update()
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height, let scrollView = scrollView {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0) })
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let scrollView = scrollView {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: { scrollView.contentInset = .zero })
        }
    }

    private func checkIfTextEmpty() {
        if let name = nameField.text, let title = titleField.text, let about = aboutField.text {
            if name.isEmpty || title.isEmpty || about.isEmpty {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let result = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage.image = result
            removePhotoButton.isEnabled = true
            dismiss(animated: true, completion: nil)
        } else {
            showAlert(title: "Failed", message: "Image can't be loaded", action: "Dismiss")
        }
    }
}
