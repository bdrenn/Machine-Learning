//Brian Drennan//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    //New bject from the class uiimagepickercontroller
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates send messages and here we send the image to our self
        imagePicker.delegate = self
        
        //uses an imagePicker with the camera
        imagePicker.sourceType = .camera
        
        // allows the user to crop the image so the framework can better understand what the object is
        imagePicker.allowsEditing = false
    }
    
    // when picture is taken it is saved in the info dictionary with data type any and a string key
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //if - this data type is downcasted as a UIImage than perform the code in the curly braces
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            
            //uses our imageview outlet and sends our new image through the image property
            imageView.image = userPickedImage
            
            // convert UIimage to CIImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
    }
        
        imagePicker.dismiss(animated: true, completion: nil) //ends the imagepicker

        
    }
    
    // detect when there is a CIImage
    func detect(image: CIImage){
        
        // creating new object of VNCoreModel and loading the model
        //added the guard because an error can be thrown and we want to understand what the error is
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreMLModel failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
        //setting the result identifier to the navigationItem title
            let firstResult = results.first?.identifier
            self.navigationItem.title = firstResult
            
            
        }
        //specified which image we want to use, the one in the parameters of the function
        let handler = VNImageRequestHandler(ciImage: image)
        
        //with a do catch block we use our handler and perform the request we created earlier on
        do {
            //try and classify the image from the request
        try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    
    //camera tapped then presents the imagePicker with animations set to true and completion set to nil because we dont need anything to happen afterward.
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        //Pressents the camera view with an animation and completion set to nil
        present(imagePicker, animated: true, completion: nil)
    }



}

