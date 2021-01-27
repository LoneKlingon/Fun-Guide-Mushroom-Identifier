//
//  EntryNewVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-07.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit

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
        
        configurePageControl()


      
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
        selectedFungus.description = store.getDescription(mName: fungName)
        print("Description: \(selectedFungus.description)")
        selectedFungus.edibility = store.getEdibility(mName: fungName)
        print("Description: \(selectedFungus.edibility)")
        selectedFungus.seasons = store.getSeason(mName: fungName)
        print("Description: \(selectedFungus.seasons)")
        selectedFungus.comName = store.getCommonName(mName: fungName)
        print("Description: \(selectedFungus.comName)")
        
        
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
            
            let displayImage:UIImage = UIImage(named: selectedFungus.cleanImages[i])!
            let imageView:UIImageView = UIImageView()
            imageView.image = displayImage
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
