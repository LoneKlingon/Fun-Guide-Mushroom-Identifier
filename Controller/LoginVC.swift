//
//  LoginVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-25.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase


class LoginVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var facebookLoginView : FBSDKLoginButton!
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        alert()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginView.delegate = self
        facebookLoginView.loginBehavior = FBSDKLoginBehavior.web
        facebookLoginView.readPermissions = ["email"]
        
        MControl.sharedInstance.startUp()
        
        if let token = FBSDKAccessToken.current()
        {
            processFbLogin()
            performSegue(withIdentifier: "LoginVCToMainVC", sender: nil)

        }
        
        if Auth.auth().currentUser != nil
        {
            performSegue(withIdentifier: "LoginVCToMainVC", sender: nil)
        }
        
    }
    
//    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
//
//        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["email", "public_profile", "gender", "user_location", "picture.type(large)"], from: self){ (result, error) in
//                if (error == nil)
//                {
//                    let fbLoginResult: FBSDKLoginManagerLoginResult = result!
//                    if fbLoginResult.grantedPermissions != nil
//                    {
//                        if(fbLoginResult.grantedPermissions.contains("email"))
//                        {
//                            self.processFbLogin()
//                        }
//                    }
//                }
//            }
//
//
//    }
    
    func alert()
    {
        
            let alert = UIAlertController(title: "Fung Guide", message: "Fun Guide  Mushroom Identifier makes no claims regarding the accuracy of its results. Please exercise caution when foraging for mushrooms. And Never Eat a mushroom you are uncertain of!", preferredStyle: .alert)
            
            
            let messageAlert = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                //

            })
            
            alert.addAction(messageAlert)
            
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        
        if ((error) != nil)
        {
            // Process error
            print("login error: \(error)")
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            //does not appear to work; use graphrequest instead
            if result.grantedPermissions.contains("email")
            {
                print("Email permission granted")
                self.processFbLogin()
                
            }
            MControl.sharedInstance.config()

//
            // Do work
            
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        print("Logged out user")
    }
    @IBAction func registerPressed(_ sender: Any)
    {
        performSegue(withIdentifier: "LoginVCToRegisterEmailUserVC", sender: nil)
        
    }
    
    @IBAction func loginPressed(_ sender: Any)
    {
    
      
        
        login()
    }

    func processFbLogin()
    {
        print("Processing login")
    
        let parameters = ["fields": "email, gender, picture.type(large), location"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { (connection, result, error) in
            
            print("Handling graph request")
            if error != nil
            {
                print(error)
                return
            }
            print("Result: \(result)")
//
            guard let resultDict = result as? [String: Any]
            else
            {
                print("Could not obtain user info")
                return
            }

            guard let email = resultDict["email"] as? String
            else
            {
                print("Could not obtain user email")
                return
            }

//            guard let location = resultDict["location"] as? String
//                else
//            {
//                print("Could not obtain user location")
//                return
//            }
//
//
//            guard let gender = resultDict["gender"] as? String
//            else
//            {
//                print("Could not obtain user gender")
//                return
//            }

//            guard let firstName = resultDict["first_name"] as? String
//            else
//            {
//                print("Could not obtain user name")
//                return
//            }
//
//            guard let lastName = resultDict["last_name"] as? String
//            else
//            {
//                print("Could not obtain user name")
//                return
//            }

//            guard let picture = resultDict["picture"] as? NSDictionary
//            else
//            {
//                print("Could not obtain user image")
//                return
//            }
//
//            guard let pictureData = picture["data"] as? NSDictionary
//            else
//            {
//                print("Could not obtain image data")
//                return
//            }
//
//            guard let url = pictureData["url"] as? String
//            else
//            {
//                print("Could not obtain image url")
//                return
//            }


            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            //print("Credential: \(credential)")
            
            print("Email: \(email)")
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    print("facebook login error: \(error)")
                    return
                }
                // User is signed in
                // ...
                print(" facebook uid: \(authResult?.user.uid)")
                if let active = authResult?.user
                {
                    print("facebook uid: \(active.uid)")



                    let db = Firestore.firestore()
                    //write to database

                    db.collection("users").document("\(active.uid)").setData([
                        "uid": active.uid,
                        "email": email,
                        "name" : active.displayName,
                        ], merge: true)


                }
            }
         
            
            
//            if let firstName = result["first_name"] as? String
//            {
//                print("first name: \(firstName)")
//            }
//
//            if let lastName = result["first_name"] as? String
//            {
//                print("first name: \(firstName)")
//            }
            
            
        }
        
        performSegue(withIdentifier: "LoginVCToMainVC", sender: nil)

    }
    
    func login()
    {
        //remember to add proper erorr testing for incorrect password, blanks, inappropriate username, taken user, etc. on all these login/register forms
        var manage = DataStore()
        
        var email = emailField.text
        
        var password = passwordField.text
        
        if (email == nil)
        {
            email = ""
        }
        
        if (password == nil)
        {
            passwordField.text = ""
        }
        
        
//        manage.signIn(email: email!, password: password!)
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error != nil
            {
                let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    //.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                MControl.sharedInstance.config()

                self.performSegue(withIdentifier: "LoginVCToMainVC", sender: nil)

            }
        }
        
    
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "LoginVCToRegisterEmailUserVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? RegisterEmailUserVC
            {
              //we're not sending anything
            }
            
        }
        
        if (segue.identifier == "LoginVCToMainVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? MainVC
            {
                //we're not sending anything
            }
            
        }
    }
    

}
