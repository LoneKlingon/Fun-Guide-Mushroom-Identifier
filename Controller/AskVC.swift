//
//  AskVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-28.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase

class AskVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    //This is the imagepicker instance
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var image1: UIImageView!
    
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var reqCommentText: UITextView!
    
    var index = 0
    
    var photosRemaining = 3
    
    var imageArr = [UIImage?]()
    
    @IBOutlet weak var photoBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    @IBAction func takePhotoPressed(_ sender: Any)
    {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func sendPressed(_ sender: Any)
    {
        sendRequest()
        MControl.sharedInstance.uploadedImage = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        checkCredits()
        checkReset()
        MControl.sharedInstance.getCreditClient()
        
        if (MControl.sharedInstance.uploadedImage == false)
        {
            clearScreen()
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoBtn.setTitle("Take Photo(\(photosRemaining))", for: .normal)
        
        //adds a done button to keyboard to end editing
        var ViewForDoneButtonOnKeyboard = UIToolbar()
        ViewForDoneButtonOnKeyboard.sizeToFit()
        var btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneBtnfromKeyboardClicked))
        ViewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
        reqCommentText.inputAccessoryView = ViewForDoneButtonOnKeyboard
        
        
        
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
    
    func alert()
    {
        let alert = UIAlertController(title: "Expert Request", message: "Your Expert Request has been sent. Please be patient and check your email for updates!", preferredStyle: .alert)
        
        if (MControl.sharedInstance.uploadError != nil)
        {
            alert.title = "Error"
            alert.message = "Upload Error: \(MControl.sharedInstance.uploadError!)"
        }
        else
        {
            //decrease credit by 1
            MControl.sharedInstance.removeCredit()
        }
        
        
        let messageAlert = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            MControl.sharedInstance.uploadError = nil
            
        })
        
        alert.addAction(messageAlert)
        
        if let alertPresentationController = alert.popoverPresentationController
        {
            alertPresentationController.sourceView = self.view
            alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkCredits()
    {
        
        DispatchQueue.main.async {
       
            MControl.sharedInstance.getCreditServer { (credits) in
                
                guard let credit = credits
                    else
                {
                    return
                }
                
                if credit == 0
                {
                    self.sendBtn.isEnabled = false
                }
                //display message
                let alert = UIAlertController(title: "No Credits", message: "To Use Ask Expert Mushroom Identification Service Add Credits to your account", preferredStyle: .actionSheet)
                
                if (credit > 0)
                {
                    alert.title = "Buy Expert Credits"
                    alert.message = "Add more Expert Identification Credits to your account"
                }
                
                
                let payAction = UIAlertAction(title: "Add credits", style: .default, handler: { (action) in
                    //in app transaction code goes here
                    
                    //InAppPurchasesService.shared.purchase(product: InAppPurchases.consumable)
                    
                    //IAPService.shared.purchaseProductAtomic(product: "com.SOBEAU.FGM.AskExpert")
                    
                    IAPService.shared.purchaseProductAtomic()
                    
                    
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
                
                
                if (credit > 0)
                {
                    self.sendBtn.isEnabled = true
                }
                
                
            }
            
        }
        
       
        
        
    }

    //ends the editing when the done button is pressed. 
    @IBAction func doneBtnfromKeyboardClicked (sender: Any)
    {
        print("Done Button Clicked.")
        //Hide Keyboard by endEditing or Anything you want.
        self.view.endEditing(true)
    }
    
    func sendRequest()
    {
        var manage = DataStore()
        manage.sendIdRequest(message: reqCommentText.text, images: imageArr)
        sendBtn.isEnabled = false
        alert()
    }
    
    
    func clearScreen()
    {
        reqCommentText.text = "Please provide as many details as possible. Size, color, location of discovery etc."
        
        image1.image = nil
        image2.image = nil
        image3.image = nil
        
        photosRemaining = 3
        index = 0
        
        photoBtn.setTitle("Take Photo(\(photosRemaining))", for: .normal)

        
        
        sendBtn.isEnabled = true
        photoBtn.isEnabled = true

    }
    
   
//    //for textviews similar to the method for textfield refer to implementation using IBAction avoe
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        if text == "\n" {
//            reqCommentText.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    
    //image picker methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let requestImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        
        switch index
        {
            case 0:
                image1.image = requestImage
                imageArr.append(requestImage)
                photosRemaining = photosRemaining - 1
                
                break
            case 1:
                image2.image = requestImage
                imageArr.append(requestImage)
                photosRemaining = photosRemaining - 1
                break
            case 2:
                image3.image = requestImage
                imageArr.append(requestImage)
                photosRemaining = photosRemaining - 1
                break
            default:
                print("image index exceeded")
        }
        
        MControl.sharedInstance.uploadedImage = true
       
        photoBtn.setTitle("Take Photo(\(photosRemaining))", for: .normal)

        index+=1
        
        if (index > 2)
        {
            photoBtn.isEnabled = false
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
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
