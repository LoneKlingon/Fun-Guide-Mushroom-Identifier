//
//  EntryNewVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-07.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase

class EntryVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var fungScroll: UIScrollView!
    
    @IBOutlet weak var sciNameLbl: UILabel!
    
    @IBOutlet weak var comNameLbl: UILabel!
    
    @IBOutlet weak var fungDesc: UITextView!
    
    @IBOutlet weak var ediblityLbl: UILabel!
    
    @IBOutlet weak var seasonLbl: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var selectedFungus = Mushroom()
    
    var fName: String?
    
    var contentWidth: CGFloat = 0.0
    
    @IBAction func backBtnPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
//    override func viewDidAppear(_ animated: Bool)
//    {
//        fungScroll.pinchGestureRecognizer?.isEnabled = false
//        fungScroll.panGestureRecognizer.isEnabled = false
//    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let imageArr = ["Agaricus augustus0.jpg", "Agaricus augustus1.jpg", "Agaricus augustus2.jpg"]

        fungScroll.delegate = self
    
        configureFung()
        configureScrollView()
        configurePageControl()
        display()

      
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        
       
        
        self.pageControl.numberOfPages = selectedFungus.cleanImages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        self.pageControl.currentPageIndicatorTintColor = UIColor.brown
        //self.view.addSubview(pageControl)
        
    }
    
    
    func configureFung()
    {
        var store = DataStore()
        
        guard let fungName = fName
            else
        {
            print ("Unable to get mushroom name")
            return
        }
        
        selectedFungus.sciName = fungName
        print("SciName: \(selectedFungus.sciName)")
        selectedFungus.rawImages = store.readImages(fname: selectedFungus.sciName)!
        print("Raw: \(selectedFungus.rawImages)")
        selectedFungus.cleanImages = store.cleanImages(rawArr: selectedFungus.rawImages)!
        print ("Clean: \(selectedFungus.cleanImages)")
        if Auth.auth().currentUser != nil
        {
            selectedFungus.description = store.getDescription(mName: fungName)
            print("Description: \(selectedFungus.description)")
            
            selectedFungus.edibility = MControl.sharedInstance.translate(rating: store.getEdibility(mName: fungName))
            
            print("Description: \(selectedFungus.edibility)")
            selectedFungus.seasons = store.getSeason(mName: fungName)
            print("Description: \(selectedFungus.seasons)")
            selectedFungus.comName = store.getCommonName(mName: fungName)
            print("Description: \(selectedFungus.comName)")
        }
        else
        {
            selectedFungus.description = "Upgrade to Pro for Offline Database Access!"
            let alert = UIAlertController(title: "Error", message: "User Session Invalid Database Is Offline", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                //.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            
            //returns nil for compact devices: iphone, etc. but true for ipads
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    func display()
    {
        sciNameLbl.text = selectedFungus.sciName
        fungDesc.text = selectedFungus.description
        ediblityLbl.text = selectedFungus.edibility
        seasonLbl.text = selectedFungus.seasons
        comNameLbl.text = selectedFungus.comName
    }
    
    func configureScrollView()
    {
        for  i in stride(from: 0, to: selectedFungus.cleanImages.count, by: 1)
        {
            
            
            var frame = CGRect.zero
            frame.origin.x = self.fungScroll.frame.size.width * CGFloat(i)
            frame.origin.y = 0
            frame.size = self.fungScroll.frame.size
            //self.fungScroll.isPagingEnabled = true

            //this will be a sharedInstance
            var mode = "free"
            let imageView:UIImageView = UIImageView()
            
            
            if (mode == "paid")
            {
                let displayImage = UIImage(named: selectedFungus.cleanImages[i])
                imageView.image = displayImage
            }
            else if(mode == "free")
            {
                print("Activating free mode: Retrieving images from cloud...")
                let storage = Storage.storage()
                
                let storageRef = storage.reference()
                
                let species = selectedFungus.sciName
                
                let imageName = selectedFungus.cleanImages[i]
                
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
                        let displayImage = image
                        imageView.image = displayImage
                        
                    }
                }
            }
            
            
            
            //imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.frame = frame
            
            fungScroll.addSubview(imageView)
        }
        self.fungScroll.contentSize = CGSize(width: self.fungScroll.frame.size.width * CGFloat(selectedFungus.cleanImages.count), height: self.fungScroll.frame.size.height)
        pageControl.addTarget(self, action: Selector(("changePage:")), for: UIControlEvents.valueChanged)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    func changePage(sender: AnyObject) -> ()
    {
        let x = CGFloat(pageControl.currentPage) * fungScroll.frame.size.width
        fungScroll.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
