//
//  MControl.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-11.
//  Copyright © 2018 AYS. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import GoogleMobileAds
import StoreKit

class MControl
{
    
    static let sharedInstance = MControl()
    
    //here as a placeholder will use userdefault to retrieve the mode 
    var mode: String!
    
    //for admob
    var interstitial: GADInterstitial!
    
    //credit status
    var cStatus: Bool?
    
    //when ask fails to upload an image
    var uploadError: Error?
    
    var uploadedImage = false
    
    
    func startUp()
    {
        var start = UserDefaults.standard.bool(forKey: "default")
        
        if (start == false)
        {
            print("Creating startup value")
            setIdentifyLimit()
            setDate()
            var date = getDate()
            setResetDate(start: date!, numOfdays: 7)
            
            var begin = true
            
            UserDefaults.standard.set(begin, forKey: "default")
        }
        else if (start == true)
        {
            print("Value already set")
        }
    }
    func config()
    {
        print("Running config...")
        print("Searching for user...")
        if let uid = Auth.auth().currentUser?.uid
        {
            print("Found uid")
            //Make sure we have the user
            if UserDefaults.standard.bool(forKey: uid)
            {
                // try to get the user default for the spacific key
                let wasConnected = UserDefaults.standard.bool(forKey: uid)
                if wasConnected
                {
                    print("This user was already registered")

                    //get mode
                    mode = getMode()
                    
                }
               
            }
                
            else
            {
                // This user was never connected
                // We set the default to his ID
                print("setting up new account")
                UserDefaults.standard.set(true, forKey: uid)
                UserDefaults.standard.synchronize()
                //setIdentifyLimit()
                setCredit()
                setRequestIndex()
                //setDate()
                //var date = getDate()
                //setResetDate(start: date!, numOfdays: 7)
                setMode(version: "free")
            }
            
        }
        else
        {
            print("Uid not found")
        }
    }
    
    func setMode(version: String)
    {
        UserDefaults.standard.set(version as? String, forKey: "version")
        mode = version
        
    }
    
    func getMode() -> String
    {
        let version = UserDefaults.standard.object(forKey: "version") as? String
        
        if (version == "full")
        {
            mode = "full"
        }
        else
        {
            mode = "free"
        }
        
        return mode
        
    }
    
    
    func translate(rating: String) -> String
    {
        var edibility: String!
        switch rating
        {
            case "yes":
                edibility = "Safe"
                break
            case "yes*":
                edibility = "Caution"
                break
            case "no":
                edibility = "Dangerous"
                break
            case "no*":
                edibility = "Not Recommended"
                break
            case "no**":
                edibility = "Unpalatable"
                break
            case "unknown":
                edibility = "Unknown"
                break
            case "unknown*":
                edibility = "Insufficient Data"
                break
            default:
                print("Unknown rating entered")
                edibility = ""
        }
        
        return edibility
    }
    
    func createAnnotationArray()
    {
        var savedAnnotations: [[String: Any]] = []

        UserDefaults.standard.set(savedAnnotations, forKey: "pins")
    }
    
    func loadAnnotations() -> [[String: Any]]
    {
        let savedAnnotations = UserDefaults.standard.object(forKey: "pins") as? [[String: Any]]
        
        if savedAnnotations == nil
        {
            print("Previous annotation not set creating array...")
            createAnnotationArray()
            
            let previousAnnotation = UserDefaults.standard.object(forKey: "pins") as? [[String: Any]]
            
            return previousAnnotation!
        }
     
        
        return savedAnnotations!
        
        
    }
    
    func addAnnotation(pin: AnnotationPin)
    {
        let locationData = ["lat": pin.coordinate.latitude, "long": pin.coordinate.longitude, "title": pin.title, "date": pin.date] as [String : Any]
        
        print("Saving annotation")
        print("Saved Pin: \(pin)")
        
        var savedAnnotations = UserDefaults.standard.object(forKey: "pins") as? [[String: Any]]
        
        savedAnnotations?.append(locationData)
        
        UserDefaults.standard.set(savedAnnotations, forKey: "pins")
       
        
    }
    
    
    
    func removeAnnotation(pin: AnnotationPin)
    {
        var savedAnnotations = UserDefaults.standard.object(forKey: "pins") as? [[String: Any]]
        
        var index = 0
        
        for location in savedAnnotations!
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

            
            
            if (oldPin.title == pin.title && oldPin.coordinate.latitude == pin.coordinate.latitude && oldPin.coordinate.longitude == pin.coordinate.longitude && oldPin.date == pin.date)
            {
                //delete pin
                print("deleting pin")
                savedAnnotations?.remove(at: index)
                
            }
        
            index+=1
            
        }
        
        UserDefaults.standard.set(savedAnnotations, forKey: "pins")
    }
    
    func setIdentifyLimit()
    {
        //weekly limit based on app payment level
        let limit = 10
        
        UserDefaults.standard.set(limit, forKey: "limit")
        
    }
    
    func setRequestIndex()
    {
        let index = 0
        UserDefaults.standard.set(index, forKey: "requestIndex")

    }
    
    func getRequestIndex() -> Int
    {
        let index = UserDefaults.standard.integer(forKey: "requestIndex")
    
        return index
    }
    
    func incrementIndex()
    {
        var index = UserDefaults.standard.integer(forKey: "requestIndex")
        
        index+=1
        
        UserDefaults.standard.set(index, forKey: "requestIndex")

    }
    
    
    
    func setDate()
    {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: "Date")
        print("Saved Date: \(currentDate)")
    }
    
    //gets the last saved date
    func getDate() -> Date?
    {
        let lastDate = UserDefaults.standard.object(forKey: "Date") as? Date
        return lastDate

    }
    
    //returns the current date
    func todaysDate() -> Date?
    {
        let today = Date()
        return today
    }
    
    func setResetDate(start:Date, numOfdays: Int)
    {
        //change .day to Calendar.Component to make it work for other values: hours, seconds, mins, etc.
        let reset = Calendar.current.date(byAdding: .day, value: numOfdays, to: start)
        UserDefaults.standard.set(reset, forKey: "Reset")

    }
    
    func getResetDate() -> Date?
    {
        let reset = UserDefaults.standard.object(forKey: "Reset") as? Date
        
        return reset
        
    }
    
    func formatDate(selectedDate: Date) -> String
    {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM/dd/yy hh:mm:ss"
        formatter.timeZone = nil
        formatter.locale = nil
        
        return formatter.string(from: selectedDate)
        
    }
    
    func isLimitReset() -> Bool
    {
        if let today = todaysDate()
        {
            print("unwrapped today")
            if let resetDate = getResetDate()
            {
                print("unwrapped reset date")
                if today >= resetDate
                {
                    return true
                }
                else
                {
                    return false
                }
            }
        }
        
        return false
        
    }
    
    func getLimit() -> Int
    {
        let limit = UserDefaults.standard.integer(forKey: "limit")
        return limit
    }
    
    func reduceLimit()
    {
        var newLimit = getLimit() - 1
        UserDefaults.standard.set(newLimit, forKey: "limit")
        
    }
    
    func checkDate()
    {
        let currentDate = UserDefaults.standard.object(forKey: "Date") as? Date
        print("Retrieved date: \(currentDate!)")
    }
    
    //admob methods
    
    func loadAd()
    {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        let request = GADRequest()
        
        interstitial.load(request)
    }
    
    func runFullAd(controller: UIViewController)
    {
        
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: controller)
        }
            
        else
        {
            print("Ad wasn't ready")
        }
        
    }
    
    func setCredit()
    {
  
        
        
        if let uid = Auth.auth().currentUser?.uid
        {
            
            //credit for expert analysis
            let user = Auth.auth().currentUser
            
            
            print("User id before: \((user?.uid)!)")
            print("User id after: \(user!.uid)")
            //create reference to db
            let db = Firestore.firestore()
            print("Setting credit to zero")
            db.collection("users").document((user!.uid)).setData([
                "credit": 0
                ], merge: true)
        }

    }
    
    func getCreditServer(completion: @escaping (Int?) -> ())
    {
        var credit: Int?
        
        if let uid = Auth.auth().currentUser?.uid
        {
            let user = Auth.auth().currentUser
            let db = Firestore.firestore()
            let docRef = db.collection("users").document((user?.uid)!)
            
            print("Retrieving document...")
            
            
            docRef.getDocument(source: .cache) { (document, error) in
                if let document = document {
                    print("Entered document block...")
                    print("Returning single field")
                    credit = document.get("credit") as? Int
                    print("Database credit value: \(credit)")
                    completion(credit)
                    
                } else {
                    print("Document does not exist in cache")
                }
            }

         
        }

        else
        {
            print("Unable to authenticate user")
        }
        
    
    }
    
    
    func getCreditClient()
    {
        getCreditServer { (credit) in
            
            guard let credits = credit
            else
            {
                print("No credit data")
                UserDefaults.standard.set(0, forKey: "credit")

                return
            }
            print("getCreditClient: \(credits)")
            UserDefaults.standard.set(credits, forKey: "credit")
            
            
        }
        
    }
    

    
    func addCredit()
    {
        
        
        if let uid = Auth.auth().currentUser?.uid
        {
            let user = Auth.auth().currentUser
            let db = Firestore.firestore()
            let docRef = db.collection("users").document((user?.uid)!)
            
            let credit = UserDefaults.standard.integer(forKey: "credit")
            print("Retrieving document...")
            
            docRef.updateData([
                "credit": credit + 1
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            
            
        }
        
        
     

    }
    
    func removeCredit()
    {
        if let uid = Auth.auth().currentUser?.uid
        {
            let user = Auth.auth().currentUser
            let db = Firestore.firestore()
            let docRef = db.collection("users").document((user?.uid)!)
            
            let credit = UserDefaults.standard.integer(forKey: "credit")
            print("Retrieving document...")
            
            docRef.updateData([
                "credit": credit - 1
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            
            
            
        }
        
    }
    
    func savePurchases(product: SKPayment)
    {
        
        var savedProducts = UserDefaults.standard.object(forKey: "appPurchases") as? [String]
        
        if (savedProducts == nil)
        {
            
            //create new array
            print("Creating new Purchase Array...")
            savedProducts = [String]()
            
            UserDefaults.standard.set(savedProducts, forKey: "appPurchases")
        }
        
        print("Saving product: \(product.productIdentifier)")
        savedProducts?.append(product.productIdentifier)
        
        UserDefaults.standard.set(savedProducts, forKey: "appPurchases")
    }
    
    func loadPurchases()
    {
        //
        guard let savedProducts = UserDefaults.standard.object(forKey: "appPurchases") as? [String]
        else
        {
            print("Empty Array")
            return
        }
        
        for product in savedProducts
        {
            print("Purchased item: \(product)")
        }
        
    }
    
    
    
    
    
    
}
