//
//  DataStore.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-23.
//  Copyright © 2018 AYS. All rights reserved.
//

import Foundation
import Firebase


struct MushroomStruct: Decodable
{
    var mushroomName: String?
    var edibility: String?
    var commonName: String?
    var preferredSearch: String?
    var season: String?
    var similarSpecies: String?
    var description: String?
    
}

//This class uploads all the images in db_imgs to firebase for later use in the mushroom database; it also contains the names of all mushrooms; it is a generla class for processing mushroom and data
class DataStore
{
 
    var imageNames = Array<String>()

    func readMushrooms() -> [String]?
    {
        let file = "complete_pure"
        
        //read the list of all mush names
        if let path = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                print ("Mushroom list: \(myStrings)")
                return myStrings
            } catch {
                print(error)
            }
        
        }
        
        return nil
    }
    
    func readImages(fname: String) -> [String]?
    {
        let file = fname
        var imagesRaw: [String]?

        if let path = Bundle.main.path(forResource: file, ofType: "txt") {
            do
            {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                imagesRaw = data.components(separatedBy: .newlines)
                
                

            } catch
            {
                print(error)
            }
            
            
        }
        
        return imagesRaw
    }
    
    
    func cleanImages(rawArr: [String]) -> [String]?
    {
        print("Cleaning images...")
        var tempImageNameArry = Array<String>()

        for iName in rawArr
        {
            var imageNameArr = iName.components(separatedBy: "/")
            print("Array Count: \(imageNameArr.count)")
            if imageNameArr.count == 3
            {
                var nameClean = imageNameArr[2]
                print (nameClean)
                tempImageNameArry.append(nameClean)
            }
            
            
        }
        
        print("Cleaned image names: \(tempImageNameArry)")
        
        return tempImageNameArry
    }
    
    
   
    func getPos(mush: String, mlist: [String]) -> Int
    {
        var pos = 0
        
        for mousseron in mlist
        {
            if (mousseron == mush)
            {
                return pos
            }
            pos+=1
            
        }
        
        return -1
    }
    
    
    func signIn(email: String, password: String)
    {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil
            {
              
                    
               
            }
            // ...
            print("\(email) signed in successfully")
        }
    }
    
    func filterData()
    {
        guard let mushroomNames = readMushrooms()
            else
        {
            print("Unable to load mushroom names")
            return
        }
        
        var aSorted = mushroomNames.filter{$0.prefix(1) == "A" }
        
        print(aSorted)
    }
    
    //implementation of csv parser imported from REM and other projects; modified to get an entry based on a key search string input
    func getDescription(mName: String) -> String
    {
        let path = Bundle.main.path(forResource: "m_list", ofType: "json")
        let mushroomURL = URL(fileURLWithPath: path!)
        
        do
        {
            let data = try Data(contentsOf: mushroomURL)
            let mushrooms = try JSONDecoder().decode([MushroomStruct].self, from: data)
            //print(mushrooms)
            
            for mushroom in mushrooms
            {
//                print(mushroom)
//                print(mushroom.mushName)
                
                if (mushroom.mushroomName! == mName)
                {
                    print ("Found entry: \(mushroom.description)")
                    return mushroom.description!
                    break
                }
            }
        }
            
        catch let jsonErr
        {
            print("Unable to get description: \(jsonErr)")
        }
            
        return ""
    }

    func getSeason(mName: String) -> String
    {
        let path = Bundle.main.path(forResource: "m_list", ofType: "json")
        let mushroomURL = URL(fileURLWithPath: path!)
        
        do
        {
            let data = try Data(contentsOf: mushroomURL)
            let mushrooms = try JSONDecoder().decode([MushroomStruct].self, from: data)
            //print(mushrooms)
            
            for mushroom in mushrooms
            {
                //                print(mushroom)
                //                print(mushroom.mushName)
                
                if (mushroom.mushroomName! == mName)
                {
                    print ("Found entry: \(mushroom.season)")
                    return mushroom.season!
                    break
                }
            }
        }
            
        catch let jsonErr
        {
            print("Unable to get description: \(jsonErr)")
        }
        
        return ""
    }
    
    func getEdibility(mName: String) -> String
    {
        let path = Bundle.main.path(forResource: "m_list", ofType: "json")
        let mushroomURL = URL(fileURLWithPath: path!)
        
        do
        {
            let data = try Data(contentsOf: mushroomURL)
            let mushrooms = try JSONDecoder().decode([MushroomStruct].self, from: data)
            //print(mushrooms)
            
            for mushroom in mushrooms
            {
                //                print(mushroom)
                //                print(mushroom.mushName)
                
                if (mushroom.mushroomName! == mName)
                {
                    print ("Found entry: \(mushroom.edibility)")
                    return mushroom.edibility!
                    break
                }
            }
        }
            
        catch let jsonErr
        {
            print("Unable to get description: \(jsonErr)")
        }
        
        return ""
    }
    func getCommonName(mName: String) -> String
    {
        let path = Bundle.main.path(forResource: "m_list", ofType: "json")
        let mushroomURL = URL(fileURLWithPath: path!)
        
        do
        {
            let data = try Data(contentsOf: mushroomURL)
            let mushrooms = try JSONDecoder().decode([MushroomStruct].self, from: data)
            //print(mushrooms)
            
            for mushroom in mushrooms
            {
                //                print(mushroom)
                //                print(mushroom.mushName)
                
                if (mushroom.mushroomName! == mName)
                {
                    print ("Found entry: \(mushroom.commonName)")
                    return mushroom.commonName!
                    break
                }
            }
        }
            
        catch let jsonErr
        {
            print("Unable to get description: \(jsonErr)")
        }
        
        return ""
    }

    func registerUser(email: String, password: String, fullname: String, country: String)
    {
        
        let db = Firestore.firestore()
        
        Auth.auth().createUser(withEmail: email, password: password)
        { (authResult, error) in
            if let registrationError = error
            {
                print("Registration Error: \(registrationError)")
            }
            else
            {
                print("Account creation successful")
                MControl.sharedInstance.config()
                
                //sign user in
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    print("User signed in")
                    
                    //write to database
                    db.collection("users").document((user?.user.uid)!).setData([
                        "uid": user?.user.uid,
                        "email": email,
                        "country": country
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }

                }

                
            }
            
        }
    

    }
    
    func sendIdRequest(message: String, images: [UIImage?])
    {
        
        if (images.count == 0)
        {
            print("Empty image array")
            MControl.sharedInstance.uploadError = NSError(domain: "No Images Selected", code: 401, userInfo: nil)
            print("Error test: \(MControl.sharedInstance.uploadError)")
        }
        
        
        Auth.auth().addStateDidChangeListener
        { (auth, user) in
            if let active = auth.currentUser
            {
                let db = Firestore.firestore()
                    //write to database
                var index = MControl.sharedInstance.getRequestIndex()
                
                
                db.collection("users").document("\(active.uid)").collection("requests").document("request[\(index)]").setData([
                    "message": message
                    ], merge: true)
                
                MControl.sharedInstance.incrementIndex()
                
                
                // Get a reference to the storage service using the default Firebase App
                let storage = Storage.storage()
                
                // Create a storage reference from our storage service
                let storageRef = storage.reference()
                
                //imageName + file extension
                var imageIndex = 0
                let requestId = MControl.sharedInstance.getRequestIndex()
                
              
                for image in images
                {
                    let data = UIImageJPEGRepresentation(image!, 1)
                    
                    let imageRef = storageRef.child("users/\(user!.uid)/request[\(requestId)]/image[\(imageIndex)].jpeg")
                    
                    // Upload the file to the path "images/rivers.jpg"
                    let uploadTask = imageRef.putData(data!, metadata: nil) { metadata, error in
                        guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            print("Image upload error")
                            MControl.sharedInstance.uploadError = error
                            return
                        }
                        print("Upload of image successful")
                    
                        // Metadata contains file metadata such as size, content-type.
                        let size = metadata.size
                        print("Size: \(size)")
                        // You can also access to download URL after upload.
                        imageRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                print("Unable to download url: \(error)")
                                return
                            }
                        }
                    }
                    imageIndex+=1
                }
                
            }
        }
        
        
    }
    
    //doesn't work because of closure in getData see DataCell's implementation that works locally on the class file 
    func downloadImage(species:String, imageName: String) -> UIImage?
    {
        let storage = Storage.storage()

        let storageRef = storage.reference()

        var image: UIImage?
        
        // Create a reference to the file you want to download
        let imageRef = storageRef.child("images/\(species)/\(imageName)")
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                image = UIImage(data: data!)
                print("Downloaded image")
            
            }
        }
        return image
        
    }
    

}
