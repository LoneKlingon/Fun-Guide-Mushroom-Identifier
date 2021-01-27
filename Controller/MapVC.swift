//
//  MapVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-05.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
   
   
    @IBOutlet weak var mushMapView: MKMapView!
    
    @IBOutlet weak var descriptionTxt: UITextField!
    
    @IBOutlet weak var locationsSegment: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    
    var mapChangedFromUserInteraction = false
    
    var currentLocation: CLLocationCoordinate2D?
    
    var pin: AnnotationPin?
    
    //saves the previously loaded annotations
    var previousAnnotations = [MKAnnotation]()
    
    @IBAction func saveBtnPressed(_ sender: Any)
    {
        saveLocation()
    }
    
    @IBAction func backBtnPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func locationsSegmentPressed(_ sender: Any)
    {
        if (locationsSegment.selectedSegmentIndex == 1)
        {
            performSegue(withIdentifier: "MapVCToLocationsVC", sender: nil)
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        
        //can be decomposed into latitude and longtitude using variable attributes
        let coordinate = location.coordinate
        currentLocation = coordinate

        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mushMapView.setRegion(region, animated: true)
        mushMapView.showsUserLocation = true
        //another altnerative is to delay the setting of map region
        locationManager.stopUpdatingLocation()
        
      
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        locationsSegment.selectedSegmentIndex = 0
        loadlocations()
        checkStatus()
        checkReset()
        
        if (MControl.sharedInstance.mode == "free")
        {
            upgrade()
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mushMapView.delegate = self

        
        descriptionTxt.delegate = self
        
        //mushMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
       
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
     
        if annotation is MKUserLocation
        {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }

        
        let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
//        guard let annotationView = mushMapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//        else
//        {
//            print("Cannot deque mapview")
//            return MKAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//        }
        
        
        annotationView.canShowCallout = true

        
        //to add image to pin
        var image = UIImage(named: "boletus_edulis_icon_v1.png")
        image = image?.scaledImage(with: CGSize(width: 15, height: 15))
        
        annotationView.image = image
        
       
        //this is the unwrapped version (apparently if let variables cannot be accessed later on
        return annotationView
    }
    
    //detects if the mapview changed based on user interacting with it
     func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mushMapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        if (mapViewRegionDidChangeFromUserInteraction())
        {
           
            //wait 15 seconds and restart tracking
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
                self.restartTracking()
            })
        }
    }
    

    func restartTracking()
    {
        locationManager.startUpdatingLocation()
    }
  
    func saveLocation()
    {
        var description = descriptionTxt.text
        if description == nil
        {
            description = ""
        }
       
        
        if let location = currentLocation
        {
            print ("location set")
            pin = AnnotationPin(title: description!, subtitle: "", coordinate: location)
            pin?.date = Date()
            print("Description: \(description)")
            mushMapView.addAnnotation(pin!)
            mushMapView.selectAnnotation(pin!, animated: true)
            MControl.sharedInstance.addAnnotation(pin: pin!)
            previousAnnotations.append(pin!)
        }
        
    }
    
    func loadlocations()
    {
    
        //reset the past data if any
        mushMapView.removeAnnotations(previousAnnotations)
        previousAnnotations.removeAll()
        
        let locations = MControl.sharedInstance.loadAnnotations()
        
        for location in locations
        {
            
            print("Location: \(location)")
            var latitude = location["lat"] as? CLLocationDegrees
            var longtitude = location["long"] as? CLLocationDegrees
            var coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longtitude!)
            print("Coord: \(coordinate)")
            var title = location["title"] as? String
            print("Coord: \(title)")
            var date = location["date"] as? Date
            var oldPin = AnnotationPin(title: title!, subtitle: "", coordinate: coordinate)
            oldPin.date = date
            print("Date: \(date)")

         
            print("oldpin: \(oldPin)")
            
            mushMapView.addAnnotation(oldPin)
            previousAnnotations.append(oldPin)
            
            
        }
        
    }
    
    func checkStatus()
    {
        
        if Auth.auth().currentUser == nil
        {
            let alert = UIAlertController(title: "Error", message: "User Session Invalid Cannot Retrieve Images", preferredStyle: .alert)
            
            
            let loginAction = UIAlertAction(title: "Login", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { (action) in
                //let's user continue on in offline mode
                print("Offline mode activated")
            }
            
            alert.addAction(loginAction)
            alert.addAction(dismissAction)
            
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            print("Valid user session")
            
        }
        
    }
    
    func checkReset()
    {
        if (MControl.sharedInstance.isLimitReset())
        {
            let today = Date()
            
            
            print("identification limit reset")
            MControl.sharedInstance.setIdentifyLimit()
            MControl.sharedInstance.setResetDate(start: today, numOfdays: 7)
        }
    }
    
    func upgrade()
    {
        //display message
        let alert = UIAlertController(title: "Upgrade", message: "Upgrade to Pro to Enjoy the Full Features of FunGuide", preferredStyle: .actionSheet)
        
        let payAction = UIAlertAction(title: "Upgrade", style: .default, handler: { (action) in
            //in app transaction code goes here
            
        })
        
        let ignoreAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            //addition code goes here
            
        })
        alert.addAction(payAction)
        alert.addAction(ignoreAction)
        
        if let alertPresentationController = alert.popoverPresentationController
        {
            alertPresentationController.sourceView = self.view
            alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        descriptionTxt.resignFirstResponder()
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
      
        
        if (segue.identifier == "MapVCToLocationsVC")
        {
            
            if let dest = segue.destination as? LocationsVC
            {
                
            }
            
        }
      
    }
    

}
////ml kit extension
///// A `UIImage` category for scaling images.
//extension UIImage {
//    /// Returns image scaled according to the given size.
//    ///
//    /// - Paramater size: Maximum size of the returned image.
//    /// - Return: Image scaled according to the give size or `nil` if image resize fails.
//    func scaledImage(with size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
//        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        // Attempt to convert the scaled image to PNG or JPEG data to preserve the bitmap info.
//        guard let image = scaledImage else { return nil }
//        let imageData = UIImagePNGRepresentation(image) ??
//            UIImageJPEGRepresentation(image, Constants.jpegCompressionQuality)
//        guard let finalData = imageData,
//            let finalImage = UIImage(data: finalData)
//            else {
//                return nil
//        }
//        return finalImage
//    }
//
//
//
//    /// Returns scaled image data from the given values.
//    ///
//    /// - Parameters
//    ///   - size: Size to scale the image to (i.e. expected size of the image in the trained model).
//    ///   - componentsCount: Number of color components for the image.
//    ///   - batchSize: Batch size for the image.
//    /// - Returns: The scaled image data or `nil` if the image could not be scaled.
//    func scaledImageData(
//        with size: CGSize,
//        componentsCount newComponentsCount: Int,
//        batchSize: Int
//        ) -> Data? {
//        guard let cgImage = self.cgImage, cgImage.width > 0 else { return nil }
//        let oldComponentsCount = cgImage.bytesPerRow / cgImage.width
//        guard newComponentsCount <= oldComponentsCount else { return nil }
//
//        let newWidth = Int(size.width)
//        let newHeight = Int(size.height)
//        let dataSize = newWidth * newHeight * oldComponentsCount
//        var imageData = [UInt8](repeating: 0, count: dataSize)
//        guard let context = CGContext(
//            data: &imageData,
//            width: newWidth,
//            height: newHeight,
//            bitsPerComponent: cgImage.bitsPerComponent,
//            bytesPerRow: oldComponentsCount * newWidth,
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
//            ) else {
//                return nil
//        }
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
//        let count = newWidth * newHeight * newComponentsCount * batchSize
//        var scaledImageDataArray = [UInt8](repeating: 0, count: count)
//        var pixelIndex = 0
//        for _ in 0..<newWidth {
//            for _ in 0..<newHeight {
//                let pixel = imageData[pixelIndex]
//                pixelIndex += 1
//
//                // Ignore the alpha component.
//                let red = (pixel >> 16) & 0xFF
//                let green = (pixel >> 8) & 0xFF
//                let blue = (pixel >> 0) & 0xFF
//                scaledImageDataArray[pixelIndex] = red
//                scaledImageDataArray[pixelIndex + 1] = green
//                scaledImageDataArray[pixelIndex + 2] = blue
//            }
//        }
//        let scaledImageData = Data(bytes: scaledImageDataArray)
//        return scaledImageData
//    }
//
//    /// Returns a scaled image data array from the given values.
//    ///
//    /// - Parameters
//    ///   - size: Size to scale the image to (i.e. expected size of the image in the trained model).
//    ///   - componentsCount: Number of color components for the image.
//    ///   - batchSize: Batch size for the image.
//    ///   - isQuantized: Indicates whether the model uses quantization. If `true`, apply
//    ///     `(value - mean) / std` to each pixel to convert the data from Int(0, 255) scale to
//    ///     Float(-1, 1).
//    /// - Returns: The scaled image data array or `nil` if the image could not be scaled.
//    func scaledImageData(
//        with size: CGSize,
//        componentsCount newComponentsCount: Int,
//        batchSize: Int,
//        isQuantized: Bool
//        ) -> [Any]? {
//        guard let cgImage = self.cgImage, cgImage.width > 0 else { return nil }
//        let oldComponentsCount = cgImage.bytesPerRow / cgImage.width
//        guard newComponentsCount <= oldComponentsCount else { return nil }
//
//        let newWidth = Int(size.width)
//        let newHeight = Int(size.height)
//        let dataSize = newWidth * newHeight * oldComponentsCount * batchSize
//        var imageData = [UInt8](repeating: 0, count: dataSize)
//        guard let context = CGContext(
//            data: &imageData,
//            width: newWidth,
//            height: newHeight,
//            bitsPerComponent: cgImage.bitsPerComponent,
//            bytesPerRow: oldComponentsCount * newWidth,
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
//            ) else {
//                return nil
//        }
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
//
//        var scaledImageData = [Any]()
//        for yCoordinate in 0..<newHeight {
//            var rowArray = [Any]()
//            for xCoordinate in 0..<newWidth {
//                var pixelArray = [Any]()
//                for component in 0..<newComponentsCount {
//                    let inputIndex =
//                        (yCoordinate * newWidth * oldComponentsCount) +
//                            (xCoordinate * oldComponentsCount + component)
//                    let pixel = imageData[inputIndex]
//                    if isQuantized {
//                        pixelArray.append(pixel)
//                    } else {
//                        // Convert pixel values from [0, 255] to [-1, 1].
//                        let pixel = (Float32(pixel) - Constants.meanRGBValue) / Constants.stdRGBValue
//                        pixelArray.append(pixel)
//                    }
//                }
//                rowArray.append(pixelArray)
//            }
//            scaledImageData.append(rowArray)
//        }
//        return [scaledImageData]
//    }
//}
//// MARK: - Fileprivate comes with ml kit uiimage extension
//
//fileprivate enum Constants {
//    static let maxRGBValue: Float32 = 255.0
//    static let meanRGBValue: Float32 = maxRGBValue / 2.0
//    static let stdRGBValue: Float32 = maxRGBValue / 2.0
//    static let jpegCompressionQuality: CGFloat = 0.8
//}
