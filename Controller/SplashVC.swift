//
//  SplashVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-23.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit

class SplashVC: UIViewController
{

    @IBAction func startBtnPressed(_ sender: Any)
    {
        //we can do some housekeeping use MControl here most likely will be done in ProfileVC
        
        performSegue(withIdentifier: "SplashVCToLoginVC", sender: nil)
     
        
    }
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "DataBookVCToEntryVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? LoginVC
            {
                //send nothing 
            }
            
        }
    }
    
}
