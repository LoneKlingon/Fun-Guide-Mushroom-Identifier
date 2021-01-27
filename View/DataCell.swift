//
//  DataCell.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-27.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase

class DataCell: UITableViewCell {
    
    @IBOutlet weak var scientificNameLbl: UILabel!
    
    @IBOutlet weak var ediblityLbl: UILabel!
    
    @IBOutlet weak var fungImage: UIImageView!
    
    var selectedFungus = Mushroom()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(mushName: String, mode: String)
    {
        var manage = DataStore()
        scientificNameLbl.text = mushName
        selectedFungus.sciName = mushName
        print("SciName: \(selectedFungus.sciName)")
        selectedFungus.rawImages = manage.readImages(fname: selectedFungus.sciName)!
        print("Raw: \(selectedFungus.rawImages)")
        selectedFungus.cleanImages = manage.cleanImages(rawArr: selectedFungus.rawImages)!

        //temporarily removed until offline storage is setup perhaps in a later version
        //        if (mode == "full")
//        {
//
//            //load image from path to the named fungus
//            //ucomment when you are ready to do testing
//            //fungImage.image = UIImage(named: selectedFungus.cleanImages[0])
//        }
//
        
        if (mode == "free" || mode == "full")
        {
            print("Free mode: Retrieving images from cloud storage...")
//            fungImage.image = manage.downloadImage(species: selectedFungus.sciName, imageName: selectedFungus.cleanImages[0])

            downloadImage(species: selectedFungus.sciName, imageName: selectedFungus.cleanImages[0])
        }
        

        selectedFungus.edibility = MControl.sharedInstance.translate(rating: manage.getEdibility(mName: mushName))
    
        
            
        ediblityLbl.text = selectedFungus.edibility
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
                self.fungImage.image = image
                
            }
        }
    }

}
