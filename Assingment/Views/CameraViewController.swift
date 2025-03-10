//
//  CameraViewController.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func capturePhototapped(_ sender: Any) {
        openImagePicker(sourceType: .camera)
    }
    
    
    @IBAction func imagePickerTapped(_ sender: Any) {
        openImagePicker(sourceType: .photoLibrary)
    }
    
    func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let selectedImage = info[.originalImage] as? UIImage {
            showFullScreenImageView(image: selectedImage)
        }
    }

    func showFullScreenImageView(image: UIImage) {
        // Create a full-screen view
        let fullScreenView = UIView(frame: view.bounds)
        fullScreenView.backgroundColor = .black
        fullScreenView.tag = 999

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = fullScreenView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        fullScreenView.addSubview(imageView)

        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 10
        closeButton.frame = CGRect(x: 20, y: 50, width: 80, height: 40)
        closeButton.addTarget(self, action: #selector(closeFullScreenImageView), for: .touchUpInside)
        fullScreenView.addSubview(closeButton)
        view.addSubview(fullScreenView)
    }

    @objc func closeFullScreenImageView() {
        if let fullScreenView = view.viewWithTag(999) {
            fullScreenView.removeFromSuperview()
        }
    }
}
