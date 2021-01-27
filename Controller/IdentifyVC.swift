//
//  IdentifyVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-07.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit

class IdentifyVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    //This is the imagepicker instance
    var imagePicker: UIImagePickerController!
    
    //image flag for when user is taking a picture
    var iFlag = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (iFlag)
        {
            let limit = MControl.sharedInstance.getLimit()
            if limit > 0 || MControl.sharedInstance.mode == "full"
            {
                takePhoto()

            }
            else
            {
                //display alert message saying no more trials remaining
                
                let alert = UIAlertController(title: "Identification Limit Reached", message: "No more free identifications remaining. Purchase Gold to use FunGuide without limitation.", preferredStyle: .alert)
                
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    //.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                
                if let alertPresentationController = alert.popoverPresentationController
                {
                    alertPresentationController.sourceView = self.view
                    alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
                
                self.present(alert, animated: true, completion: nil)
                
                print("No more identifications remaining! Please try again later or buy Gold.")
            }
            
            
        }
        else
        {
            iFlag = true
        }
    }
    
    func takePhoto()
    {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    //image picker methods 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let mush = info[UIImagePickerControllerOriginalImage] as? UIImage
        //send image to Identity VC for processing
        iFlag = false
        
        MControl.sharedInstance.reduceLimit()

        self.dismiss(animated: true)
        {
            self.performSegue(withIdentifier: "IdentifyVCtoIdentityVC", sender: mush)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        iFlag = false

        self.dismiss(animated: true)
        {
            self.performSegue(withIdentifier: "IdentifyVCtoMainVC", sender: nil)
            
        }
    }
    
  

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "IdentifyVCtoIdentityVC")
        {
            
            if let dest = segue.destination as? IdentityVC
            {
                if let image = sender as? UIImage
                {
                    dest.mush = image
                }
            }
            
        }
        if (segue.identifier == "IdentifyVCtoMainVC")
        {
            if let dest = segue.destination as? MainVC
            {
                
            }
        }
    }
    

}
