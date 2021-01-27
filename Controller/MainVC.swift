//
//  MainVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-12.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController{



    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
      

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadModel()
    {
        let conditions = ModelDownloadConditions(isWiFiRequired: true, canDownloadInBackground: true)
        let cloudModelSource = CloudModelSource(
            modelName: "guide-test",
            enableModelUpdates: true,
            initialConditions: conditions,
            updateConditions: conditions
        )
        let registrationSuccessful = ModelManager.modelManager().register(cloudModelSource)
    }
    
   //firebase api has changed 
    func runModel()
    {
//        print("Running model")
//
//        //load Model on cloud
////        let conditions = ModelDownloadConditions(wiFiRequired: true, idleRequired: true)
////        let cloudModelSource = CloudModelSource(
////            modelName: "guide-test",
////            enableModelUpdates: true,
////            initialConditions: conditions,
////            updateConditions: conditions
////        )
////        let registrationSuccessful = ModelManager.modelManager().register(cloudModelSource)
////
//        guard let modelPath = Bundle.main.path(
//            forResource: "guide",
//            ofType: "tflite"
//            ) else {
//                // Invalid model path
//                print("Invalid model path")
//                return
//        }
//        let localModelSource = LocalModelSource(modelName: "guide",
//                                                path: modelPath)
//        let registrationSuccessful = ModelManager.modelManager().register(localModelSource)
//
//        let options = ModelOptions(
//            cloudModelName: "",
//            //used for local storage
//            localModelName: "guide"
//        )
//
//
//        //create interpreter instance
//        let interpreter = ModelInterpreter()
//
//        //set input/output
//        let ioOptions = ModelInputOutputOptions()
//        do {
//            try ioOptions.setInputFormat(index: 0, type: .uInt8, dimensions: [1, 640, 480, 1])
//            try ioOptions.setOutputFormat(index: 0, type: .float32, dimensions: [1, 9])
//        } catch let error as NSError {
//            print("Failed to set input or output format with error: \(error.localizedDescription)")
//        }
//
//        //assign data to input
//        let input = ModelInputs()
//
//        do {
//            var data: Data  // or var data: Array
//            // Store input data in `data`
//
//            //            let imageUrlString = "http://www.naturephoto-cz.com/photos/maly/cantharellus-cibarius-49x_1725.jpg"
//            //
//            //            let imageUrl = URL(string: imageUrlString)!
//            //
//            //            let imageData = try! Data(contentsOf: imageUrl)
//            //            //let image = UIImage(data: imageData) //Displays the image
//            let imageData = UIImage(named: "canth.jpg")?.resizeTo(CGSize(width: 640, height: 480))
//
//
//
//            data = UIImageJPEGRepresentation(imageData!, 1)!
//
//
//            //data = (imageData?.scaledImageData(with: CGSize(width: 640, height: 480), componentsCount: 1, batchSize: 1))!
//
//
//            // add data to input
//            try input.addInput(data)
//            // Repeat as necessary for each input index
//            print("Attached data")
//        } catch let error as NSError {
//            print("Failed to add input: \(error.localizedDescription)")
//        }
//        print("Running interpreter")
//
//        //identify
//        interpreter.run(inputs: input, options: ioOptions) { outputs, error in
//            print("Retrieving results")
//            guard error == nil, let outputs = outputs else {
//                print("Could not retrieve results: \(error)")
//                return
//
//            }
//            // Process outputs
//            // Get first and only output of inference with a batch size of 1
//            let probabilities = try? outputs.output(index: 0)
//            print("Retrieved results")
//            print("The result of the image is \(probabilities)")
//        }
 
    }
    

    @IBAction func identifyPressed(_ sender: Any)
    {
        //runModel()
        
        //runCoreMLModel()
        
        //Take the photo
        //takePhoto()
        
        performSegue(withIdentifier: "MainVCtoIdentifyVC", sender: nil)

        
    }
    
    @IBAction func askPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "MainVCToAskVC", sender: nil)
    }
    
    
    @IBAction func searchPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "MainVCToDataBookVC", sender: nil)
    }
    
    
    
    
    
    func runCoreMLModel()
    {
        var model = Guide()
        
        let imageData = UIImage(named: "mo_1.jpeg")?.scaledImage(with: CGSize(width: 224, height: 224))
        
        
        
        let output = try? model.prediction(input__0: (imageData?.buffer())!)
        //most probable prediction
        let prediction = output?.classLabel
        print("Prediction: \(prediction)")
        
        //all of the results
        let predictions = output?.final_result__0
        
        for (label, percentage) in predictions!
        {
            print("label: \(label) percentage:\(percentage)")
        }
    }
    
  
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "MainVCtoIdentifyVC")
        {
            
            if let dest = segue.destination as? IdentifyVC
            {
                if let image = sender as? UIImage
                {
                    
                }
            }
            
        }
        
        if (segue.identifier == "MainVCToDataBookVC")
        {
            if let dest = segue.destination as? DataBookVC
            {
                //do nothing 
            }
        }
        
        if (segue.identifier == "MainVCToAskVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? AskVC
            {
                //we're not sending anything
            }
            
        }
    }
        

}
