//
//  ProfileVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-21.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class ProfileVC: UIViewController, GADBannerViewDelegate{

    @IBOutlet weak var accessLbl: UILabel!
    
    @IBOutlet weak var emailLbl: UILabel!

    @IBOutlet weak var identificationLbl: UILabel!
    
    @IBOutlet weak var resetLbl: UILabel!
    
    @IBOutlet weak var creditLbl: UILabel!
    
    @IBOutlet weak var profileAd: GADBannerView!
    
    @IBOutlet weak var profileFrame: UIView!
    
    @IBOutlet weak var mainFrame: UIView!
    
    @IBOutlet weak var identificationLeft: UILabel!
    
    @IBOutlet weak var resetDate: UILabel!
    
    var timer : Timer?

    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        creditLbl.text = "Loading..."
        
        let request = GADRequest()
    
        //test id
        //profileAd.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        profileAd.adUnitID = "ca-app-pub-2762075992313293/8410704570"
        profileAd.rootViewController = self
        profileAd.delegate = self
        profileAd.load(request)
        
        checkCredit()
        
        IAPService.shared.getProductInfo(products: ["com.SOBEAU.FGM.FullVersion"])
        IAPService.shared.getProductInfo(products: ["com.SOBEAU.FGM.AskExpert"])

        
        
    }
    
    @IBAction func restorePurchasesBtnPressed(_ sender: Any)
    {
        IAPService.shared.restorePurchasesNonAtomic()
        controlLabels()
    }
    
    
    func checkCredit()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ProfileVC.updateCredit), userInfo: nil, repeats: true)
    }
    
    
    
    @objc func updateCredit()
    {
        let result = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: creditLbl.text!))
        
        if (result == true)
        {
            //stops the timer
            print("Stopping the timer")
            timer?.invalidate()
            MControl.sharedInstance.cStatus = false
        }
        
       
        
        
        DispatchQueue.main.async
        {
            MControl.sharedInstance.getCreditServer { (credit) in
                
                if (credit != nil)
                {
                    self.creditLbl.text = String(describing: credit!)
                    
                }
                    
                else
                {
                    self.creditLbl.text = "0"
                }
                
            }
            
        }
       
     

    }
    
    func controlLabels()
    {
        accessLbl.text = MControl.sharedInstance.mode.capitalizingFirstLetter()
        
        if (MControl.sharedInstance.mode == "full")
        {
            identificationLbl.isHidden = true
            identificationLeft.isHidden = true
            
            resetLbl.isHidden = true
            resetDate.isHidden = true
            
            profileAd.isHidden = true
        }
            
        else
        {
            identificationLbl.isHidden = false
            identificationLeft.isHidden = false
            
            resetLbl.isHidden = false
            resetDate.isHidden = false
            
            profileAd.isHidden = false
        }
        
    }
    
    func display()
    {
        
        controlLabels()
        
        
        identificationLbl.text = String(describing: MControl.sharedInstance.getLimit())
        
        
        
            updateCredit()
        
        if let date = MControl.sharedInstance.getResetDate()
        {
            let resetDate = MControl.sharedInstance.formatDate(selectedDate: date)
            
            resetLbl.text = resetDate
            
        }
        
        Auth.auth().addStateDidChangeListener
            { (auth, user) in
                if let active = auth.currentUser
                {
                    if (user?.email != nil)
                    {
                        self.emailLbl.text = user!.email
                    }
                    else
                    {
                        self.emailLbl.text = ""
                    }
                
                }
            }
        
        
        
    }
    override func viewDidAppear(_ animated: Bool)
    {
        checkStatus()
        checkReset()
        display()
        if (MControl.sharedInstance.mode == "free")
        {
            upgrade()

        }
        MControl.sharedInstance.loadPurchases()
    
        if (MControl.sharedInstance.cStatus == true)
        {
            creditLbl.text = "Loading"
            checkCredit()
        }
        
        MControl.sharedInstance.getCreditClient()
        IAPService.shared.checkDownloads()
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
            
            //As said before, you should configure UIAlertController to be presented on a specific point on iPAD.
            //Example for navigation bar
            //alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            
            //same as above but an alternate solution
            //alert.popoverPresentationController?.sourceView = self.view
            //alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)

            
            //returns nil for compact devices: iphone, etc. but true for ipads
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.mainFrame
                alertPresentationController.sourceRect = CGRect(x: self.mainFrame.bounds.midX-160, y: self.mainFrame.bounds.midY, width: 0, height: 0)
            }
            
            
            self.present(alert, animated: true, completion: nil)
        }
            
        else
        {
            print("Valid user session")
            
        }
        
    }
    
    //later versions will use server timestamp 
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
            //InAppPurchasesService.shared.getProducts()
            //InAppPurchasesService.shared.purchase(product: InAppPurchases.noncomsumable)
            IAPService.shared.purchaseNonAtomic()
            
        })
        
        let ignoreAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
            //addition code goes here
            
        })
        alert.addAction(payAction)
        alert.addAction(ignoreAction)
        
        //alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        //returns nil for compact devices: iphone, etc. but true for ipads
        if let alertPresentationController = alert.popoverPresentationController
        {
            alertPresentationController.sourceView = self.mainFrame
            alertPresentationController.sourceRect = CGRect(x: self.mainFrame.bounds.midX-160, y: self.mainFrame.bounds.midY, width: 0, height: 0)
            
        }
        self.present(alert, animated: true, completion: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
