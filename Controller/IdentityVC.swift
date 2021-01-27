//
//  IdentityVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-19.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class IdentityVC: UIViewController, GADInterstitialDelegate  {
   
    @IBOutlet weak var mLabel: UILabel!
    
    @IBOutlet weak var mImage: UIImageView!
    
    var iterator: IndexingIterator<[(key: String, value: Double)]>?
    var predictionsCopy: Dictionary<String, Double>?
    var sortedDictionary : [(key: String, value: Double)]?
    var predictionCopy: String?
    var mush: UIImage?
    var mushName: String?
    
    //let's us know if the viewcontroller has loaded for the first time
    var initialFlag = true

    var interstitial: GADInterstitial!
    
    //triggers true when ad is closed after matchbtn is pressed
    var adFlag = false

    var mode = ""

    
    //keeps track of first position in predictions dict which is not the first result of the identity scan
    var pos = 0
    @IBAction func matchBtnPressed(_ sender: Any)
    {
        //show info
        
        mode = "match"
        
        
        if (MControl.sharedInstance.mode == "free")
        {
            runAd()
        }
        else
        {
            performSegue(withIdentifier: "IdentityVCToEntryVC", sender: mushName)
        }
        
    }
    
    @IBAction func againBtnPressed(_ sender: Any)
    {
        //show next result
        mode = "next"
        if (MControl.sharedInstance.mode == "free")
        {
            runAd()
        }
        nextGuess()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
//        if (initialFlag != true)
//        {
//            loadAd()
//        }

        
        if (MControl.sharedInstance.mode == "free")
        {
           loadAd()
        }
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        processImage()
        
        
        if (MControl.sharedInstance.mode == "free")
        {
            loadAd()
        }
        
        //initialFlag = false
    }
    
    func loadAd()
    {
        //test id
        //interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
       
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2762075992313293/1868937832")
        
        interstitial.delegate = self

        let request = GADRequest()
        
        
        interstitial.load(request)
        print("ad request loaded")
    }
    
    func runAd()
    {
        
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: self)
        }
            
        else
        {
            print("Ad wasn't ready")
            if (mode == "match")
            {
                performSegue(withIdentifier: "IdentityVCToEntryVC", sender: mushName)
            }
            
        }
        
        
    }
    
   
    
    
    @IBAction func backBtnPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "IdentityVCtoMainVC", sender: nil)
    }
    
   
    
    func processImage()
    {
        
        if (mush != nil)
        {
           runCoreMLModel(image: mush!)
        }
        
    
    }
    
    func setImage(imageName: String)
    {
    
        //temporary image
        mImage.image = UIImage(named: "image_placeholder.png")
        
        //supposed to load stored image in full but we are no longer doing that
       
            print("free mode activated downloading images")
                
            
            var manage = DataStore()
            let species = imageName
            let raw = manage.readImages(fname: species)
            let clean = manage.cleanImages(rawArr: raw!)
            let image = clean![0]
        
            downloadImage(species: species, imageName: image)
            
            
        
    }
    
    func downloadImage(species: String, imageName: String)
    {
        let storage = Storage.storage()
        
        let storageRef = storage.reference()
        
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(species)/\(imageName)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Unable to retrieve image")
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                print("Downloaded image")
                self.mImage.image = image
                
            }
        }
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
    
    func runModel()
    {
//        print("Running model")
//
//        //load Model on cloud
//        //        let conditions = ModelDownloadConditions(wiFiRequired: true, idleRequired: true)
//        //        let cloudModelSource = CloudModelSource(
//        //            modelName: "guide-test",
//        //            enableModelUpdates: true,
//        //            initialConditions: conditions,
//        //            updateConditions: conditions
//        //        )
//        //        let registrationSuccessful = ModelManager.modelManager().register(cloudModelSource)
//        //
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
//        let interpreter = ModelInterpreter(options: options)
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
    
    
    
    func nextGuess()
    {
    
        var localPos = 0
       
      //it looks more like an array than a dictionary
        print("Sorted Dictionary: \(sortedDictionary)")
        
        if (pos > 2)
        {
            pos = 0
        }
   
      
        mLabel.text = sortedDictionary![pos].key.capitalizingFirstLetter()
        mushName = sortedDictionary![pos].key.capitalizingFirstLetter()
        setImage(imageName: mushName!)
        pos+=1
        
      

        
//        //This has to be done because the first predicted result is not the same as the first result in the predictions dictionary
//
//        if (pos < 4)
//        {
//
//            if let guess = iterator?.next()?.key
//            {
//
//                mLabel.text = guess.capitalizingFirstLetter()
//                mushName = guess.capitalizingFirstLetter()
//                setImage(imageName: mushName!)
//                pos+=1
//
//            }
//        }
//
//
//
//
//        else if (pos == 4)
//        {
//            if let guess = predictionCopy
//            {
//
//                mLabel.text = guess.capitalizingFirstLetter()
//                mushName = guess.capitalizingFirstLetter()
//                setImage(imageName: mushName!)
//                pos = 1
//
//            }
//
//            iterator = sortedDictionary?.makeIterator()
//
//        }
//
        
        
    }

    
    
    func runCoreMLModel(image: UIImage)
    {
        var model = Guide()
        
        let imageData = image.scaledImage(with: CGSize(width: 224, height: 224))
        
        
        
        let output = try? model.prediction(input__0: (imageData?.buffer())!)
        //most probable prediction
        let prediction = output?.classLabel
        print("Prediction: \(prediction)")
        
        //set label to most probable
        //mLabel.text = prediction!.capitalizingFirstLetter()
        //mushName = prediction!.capitalizingFirstLetter()
        //setImage(imageName: mushName!)
        predictionCopy = prediction
        
        //setImage(imageName: mushName!)
        
        //all of the results
        let predictions = output?.final_result__0
        predictionsCopy = predictions
        
        
        sortedDictionary = predictionsCopy?.sorted(by: { $0.value > $1.value })
        nextGuess()
       
        
        iterator = sortedDictionary?.makeIterator()
        
        
        for (label, percentage) in predictions!
        {
            print("label: \(label) percentage:\(percentage)")
        }
    }
    
    //detects when admob ad is closed
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial)
    {
       
        
        
    }
    
    //detects when admob ad is closed
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialDidDismissScreen")
        
        if (mode == "match")
        {
            performSegue(withIdentifier: "IdentityVCToEntryVC", sender: mushName)
        }
        print("mode: \(mode)")
        
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "IdentityVCToEntryVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? EntryVC
            {
                //send data of type Home to destination VC
                if let choice = sender as? String
                {
                    dest.fName = choice
                }
            }
            
        }
        if (segue.identifier == "IdentityVCtoMainVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? MainVC
            {
                //send data of type Home to destination VC
                if let choice = sender as? String
                {
                    
                }
            }
            
        }
        
    }
    
}

//capitalized first letter ext
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}



//coreml extension
extension UIImage {
    func buffer() -> CVPixelBuffer? {
        return UIImage.buffer(from: self)
    }
    
    // Taken from:
    // https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer
    // https://www.hackingwithswift.com/whats-new-in-ios-11
    static func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resizeTo(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
//ml kit extension
/// A `UIImage` category for scaling images.
extension UIImage {
    /// Returns image scaled according to the given size.
    ///
    /// - Paramater size: Maximum size of the returned image.
    /// - Return: Image scaled according to the give size or `nil` if image resize fails.
    func scaledImage(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Attempt to convert the scaled image to PNG or JPEG data to preserve the bitmap info.
        guard let image = scaledImage else { return nil }
        let imageData = UIImagePNGRepresentation(image) ??
            UIImageJPEGRepresentation(image, Constants.jpegCompressionQuality)
        guard let finalData = imageData,
            let finalImage = UIImage(data: finalData)
            else {
                return nil
        }
        return finalImage
    }
    
    
    
    /// Returns scaled image data from the given values.
    ///
    /// - Parameters
    ///   - size: Size to scale the image to (i.e. expected size of the image in the trained model).
    ///   - componentsCount: Number of color components for the image.
    ///   - batchSize: Batch size for the image.
    /// - Returns: The scaled image data or `nil` if the image could not be scaled.
    func scaledImageData(
        with size: CGSize,
        componentsCount newComponentsCount: Int,
        batchSize: Int
        ) -> Data? {
        guard let cgImage = self.cgImage, cgImage.width > 0 else { return nil }
        let oldComponentsCount = cgImage.bytesPerRow / cgImage.width
        guard newComponentsCount <= oldComponentsCount else { return nil }
        
        let newWidth = Int(size.width)
        let newHeight = Int(size.height)
        let dataSize = newWidth * newHeight * oldComponentsCount
        var imageData = [UInt8](repeating: 0, count: dataSize)
        guard let context = CGContext(
            data: &imageData,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: oldComponentsCount * newWidth,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let count = newWidth * newHeight * newComponentsCount * batchSize
        var scaledImageDataArray = [UInt8](repeating: 0, count: count)
        var pixelIndex = 0
        for _ in 0..<newWidth {
            for _ in 0..<newHeight {
                let pixel = imageData[pixelIndex]
                pixelIndex += 1
                
                // Ignore the alpha component.
                let red = (pixel >> 16) & 0xFF
                let green = (pixel >> 8) & 0xFF
                let blue = (pixel >> 0) & 0xFF
                scaledImageDataArray[pixelIndex] = red
                scaledImageDataArray[pixelIndex + 1] = green
                scaledImageDataArray[pixelIndex + 2] = blue
            }
        }
        let scaledImageData = Data(bytes: scaledImageDataArray)
        return scaledImageData
    }
    
    /// Returns a scaled image data array from the given values.
    ///
    /// - Parameters
    ///   - size: Size to scale the image to (i.e. expected size of the image in the trained model).
    ///   - componentsCount: Number of color components for the image.
    ///   - batchSize: Batch size for the image.
    ///   - isQuantized: Indicates whether the model uses quantization. If `true`, apply
    ///     `(value - mean) / std` to each pixel to convert the data from Int(0, 255) scale to
    ///     Float(-1, 1).
    /// - Returns: The scaled image data array or `nil` if the image could not be scaled.
    func scaledImageData(
        with size: CGSize,
        componentsCount newComponentsCount: Int,
        batchSize: Int,
        isQuantized: Bool
        ) -> [Any]? {
        guard let cgImage = self.cgImage, cgImage.width > 0 else { return nil }
        let oldComponentsCount = cgImage.bytesPerRow / cgImage.width
        guard newComponentsCount <= oldComponentsCount else { return nil }
        
        let newWidth = Int(size.width)
        let newHeight = Int(size.height)
        let dataSize = newWidth * newHeight * oldComponentsCount * batchSize
        var imageData = [UInt8](repeating: 0, count: dataSize)
        guard let context = CGContext(
            data: &imageData,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: oldComponentsCount * newWidth,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        var scaledImageData = [Any]()
        for yCoordinate in 0..<newHeight {
            var rowArray = [Any]()
            for xCoordinate in 0..<newWidth {
                var pixelArray = [Any]()
                for component in 0..<newComponentsCount {
                    let inputIndex =
                        (yCoordinate * newWidth * oldComponentsCount) +
                            (xCoordinate * oldComponentsCount + component)
                    let pixel = imageData[inputIndex]
                    if isQuantized {
                        pixelArray.append(pixel)
                    } else {
                        // Convert pixel values from [0, 255] to [-1, 1].
                        let pixel = (Float32(pixel) - Constants.meanRGBValue) / Constants.stdRGBValue
                        pixelArray.append(pixel)
                    }
                }
                rowArray.append(pixelArray)
            }
            scaledImageData.append(rowArray)
        }
        return [scaledImageData]
    }
}

// MARK: - Fileprivate comes with ml kit uiimage extension

fileprivate enum Constants {
    static let maxRGBValue: Float32 = 255.0
    static let meanRGBValue: Float32 = maxRGBValue / 2.0
    static let stdRGBValue: Float32 = maxRGBValue / 2.0
    static let jpegCompressionQuality: CGFloat = 0.8
}

//convert images to 8 bit pixel
extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}
