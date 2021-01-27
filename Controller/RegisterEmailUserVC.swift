//
//  RegisterEmailUserVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-03.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase

class RegisterEmailUserVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //IBOutlets
    @IBOutlet weak var fullnameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var countryPicker: UIPickerView!
    
    //runtime variables
    var countries = [String]()
    var unsortedCountries = [String]()
    var currentCountry: String?
    

    @IBAction func backBtnPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerBtnPressed(_ sender: Any)
    {
        register()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        parseCountryJSON()
        countryPicker.delegate = self
        countryPicker.dataSource = self
        fixCountries()
        
        emailText.delegate = self
        passwordText.delegate = self
        fullnameText.delegate = self
        
        
    }
    
    func register()
    {
        var store =  DataStore()
        
        
        guard let fullname = fullnameText.text
        else
        {
            
            let alert = UIAlertController(title: "Error", message: "Please enter your name.", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                return
            })
            alert.addAction(okAction)
            
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        guard let country = currentCountry
        else
        {
            
            let alert = UIAlertController(title: "Error", message: "Please select a country.", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                return
            })
            alert.addAction(okAction)
            
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
            return
        }
            
        if (country != "" && fullname != "" && country != "Country")
        {
            
            let db = Firestore.firestore()
            
            let password = passwordText.text!
            let email = emailText.text!
            
            
            Auth.auth().createUser(withEmail: email, password: password)
            { (authResult, error) in
                
                if let registrationError = error
                {
                    print("Registration Error: \(registrationError)")
                   
                    let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                    
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
                
                }
                    
                else
                {
                    print("Account creation successful")
                    
                    //sign user in
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        print("User signed in")
                        
                        MControl.sharedInstance.config()

                        if error != nil
                        {
                            let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                            
                            
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
                            
                        }
                            
                        else
                        {
                            
                            db.collection("users").document((user?.user.uid)!).setData([
                                "uid": user?.user.uid,
                                "email": email,
                                "country": country
                            ], merge: true) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                            
                            self.performSegue(withIdentifier: "RegisterEmailUserVCToMainVC", sender: nil)
                            
                        }

                        
                    }
                    
                    
                }
                
            }
            
            
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Please fill out the entire form.", preferredStyle: .alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
            })
            alert.addAction(okAction)
            
            if let alertPresentationController = alert.popoverPresentationController
            {
                alertPresentationController.sourceView = self.view
                alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    //copy and pasted from REM
    func parseCountryJSON() {
        do {
            if let file = Bundle.main.url(forResource: "countries", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print("Printing json dict: \(object)")
                    print("Testing, testing, 1, 2, 3")
                    
                    
                } else if let object = json as? [Any] {
                    // json is an array
                    print("Printing json array: \(object)")
                    
                    for dictObject in object
                    {
                        if let dict = dictObject as? [String: Any]
                        {
                            if let nameDict = dict["name"] as? [String: Any]
                            {
                                if let name = nameDict["common"] as? String
                                {
                                    unsortedCountries.append(name)
                                   
                                    
                                    //test code comment out or delete from final version everything below
                                    print("added \(name) dict")
                                
                                }
                            }
                        }
                        
                        
                    }
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
   
    func fixCountries()
    {
        countries = unsortedCountries.sorted()
        
        countries.insert("Country", at: 0)
        
//        var usa = countries.index(of: "United States")
//        countries.remove(at: usa!)
//        countries.insert("United States", at: 1)
//
//        var can = countries.index(of: "Canada")
//        countries.remove(at: can!)
//        countries.insert("Canada", at: 2)
//
//        var uk = countries.index(of: "United Kingdom")
//        countries.remove(at: uk!)
//        countries.insert("United Kingdom", at: 3)
//
//        var aus = countries.index(of: "Australia")
//        countries.remove(at: aus!)
//        countries.insert("Australia", at: 4)
        
        countryPicker.reloadAllComponents()
    }
    func updateCountry(update: String)
    {
        currentCountry = update
    }

    //pickerview delegate methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let selectedCountry = countries[row]
        print("Current country: \(selectedCountry)")
        updateCountry(update: selectedCountry)
    }

    
    //textfield delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //when return is pressed keyboard disappears
        emailText.resignFirstResponder()
        fullnameText.resignFirstResponder()
        passwordText.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "RegisterEmailUserVCToMainVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? MainVC
            {
                //we're not sending anything
            }
            
        }
    }
    

}
