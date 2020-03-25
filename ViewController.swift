//
//  ViewController.swift
//  FlowerDetection
//
//  Created by Rishabh on 25/03/20.
//  Copyright © 2020 Rishabh. All rights reserved.
//

import UIKit
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    let imagepicker = UIImagePickerController()
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    

    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagepicker.delegate = self
        imagepicker.allowsEditing = false
        imagepicker.sourceType = .photoLibrary
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            backImage.image = userPickedImage
        
            guard let pickedCiimage = CIImage(image: userPickedImage) else {fatalError()}
            detect(image: pickedCiimage)
        }
        
        imagepicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image : CIImage){
        
        guard let mainModel = try? VNCoreMLModel(for: FlowerClassifer().model) else{fatalError("model not loaded")}
        
        let req = VNCoreMLRequest(model: mainModel) { (req, error) in
            guard let result = req.results?.first as? VNClassificationObservation else{fatalError()}
            self.navigationItem.title = result.identifier.capitalized
            
            self.reqInfo(Flowername: result.identifier)
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
           try handler.perform([req])
        }
        catch{
            print(error)
        }
    
    }
    
    func reqInfo(Flowername : String){
        
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : Flowername,
            "indexpageids" : "",
            "redirects" : "1",
            ]
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess{
                print(response.result)
                
                let res : JSON  = JSON(response.result.value!)
                
                let pageid = res["query"]["pageids"][0].stringValue
                
                let info = res["query"]["pages"][pageid]["extract"].stringValue
                
                self.labelInfo.text = info
              
            }
        }
        
    }

    @IBAction func camPressed(_ sender: UIBarButtonItem) {
        mainLabel.alpha = 0.0
        present(imagepicker, animated: true, completion: nil)
        
    }
    
    
}

