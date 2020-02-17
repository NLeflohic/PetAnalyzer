//
//  ViewController.swift
//  PetAnalyzer
//
//  Created by nicolas le flohic on 17/02/2020.
//  Copyright © 2020 nicolas le flohic. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var petLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    var alert : UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.showsCameraControls = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageTaken = info[.originalImage] as? UIImage {
            imageView.image = imageTaken
            if let detectImage = CIImage(image: imageTaken) {
                detect(imageToDetect: detectImage)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect (imageToDetect: CIImage) {
        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {
            DispatchQueue.main.async {
                self.alert = UIAlertController(title: "Warning", message: "Unable to convert the model", preferredStyle: .alert)
                self.alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(self.alert, animated: true, completion: nil)
            }
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                DispatchQueue.main.async {
                    self.alert = UIAlertController(title: "Warning", message: "Unable to create the model", preferredStyle: .alert)
                    self.alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(self.alert, animated: true, completion: nil)
                }
                return
            }
            if let label = results.first {
                DispatchQueue.main.async {
                    self.petLabel.text = "It's a \(label.identifier)"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: imageToDetect)
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.alert = UIAlertController(title: "Warning", message: "Unable to perform the request", preferredStyle: .alert)
                self.alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(self.alert, animated: true, completion: nil)
            }
            return
        }
    }
    
}

