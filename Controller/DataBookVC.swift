//
//  DataBookVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-27.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class DataBookVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var tableView: UITableView!
    
    var mlist = [String]() //equivalent of words
    var mlistSection = [String]() //equivalent of wordsSection
    var mlistDict = [String: [String]]() // eq of wordsDict
    
    var searchMlist = [String]() //stores the filtered search results on mlist current value of list
    
    var interstitial: GADInterstitial!

    var mushName: String?
    
    override func viewDidAppear(_ animated: Bool) {
        checkStatus()
        checkReset()
        if (MControl.sharedInstance.mode == "free")
        {
            loadAd()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
     
        
        let getData = DataStore()
        if let mushData = getData.readMushrooms()
        {
            print("Getting data")
            mlist = mushData
            searchMlist = mlist
            printData()
       
        }
        
        generateDict()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        

        
        //sets the text color and background color for the index
        tableView.sectionIndexColor = UIColor.white
        //alpha = opacity setting
        tableView.sectionIndexBackgroundColor = UIColor(hexString: "#945200", alpha: 0.77)
        
        
    }
    func printData()
    {
        print(mlist)
    }
    
    func clearAll()
    {
        mlistSection.removeAll()
        mlistDict.removeAll()
    }
    
    func generateDict()
    {
        for mousseron in searchMlist
        {
            if mousseron != ""
            {
                let key = "\(mousseron[mousseron.startIndex])"
                let upper = key.uppercased()
                
                if var mousseronValues = mlistDict[upper]
                {
                    mousseronValues.append(mousseron)
                    mlistDict[upper] = mousseronValues
                }
                else
                {
                    mlistDict[upper] = [mousseron]
                }
            }
            
        }
        
        mlistSection = [String](mlistDict.keys)
        mlistSection = mlistSection.sorted()
        //print("Sections: \(mlistSection)")
        //print("Dictionary entries: \(mlistDict)")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let mushKey = mlistSection[section]
        if let mushValues = mlistDict[mushKey]
        {
            return mushValues.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as? DataCell
    
        let mushKey = mlistSection[indexPath.section]
        if let mushValues = mlistDict[mushKey.uppercased()]
        {
            cell?.updateCell(mushName: mushValues[indexPath.row], mode: MControl.sharedInstance.mode)
            
        }
        
        
        return cell!
       
        
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return mlistSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mlistSection[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return mlistSection
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mushKey = mlistSection[indexPath.section]
        if let mushValues = mlistDict[mushKey.uppercased()]
        {
             mushName = mushValues[indexPath.row]
            print("Mushroom name: \(mushName)")
            if (MControl.sharedInstance.mode == "free")
            {
                runAd()
            }
            else
            {
                performSegue(withIdentifier: "DataBookVCToEntryVC", sender: mushName)

            }
            
        }
    }
    
    //searchbar delegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //For the case when a "" is entered into the searchbar
        guard (!searchText.isEmpty)
        else
        {
            searchMlist = mlist
            tableView.reloadData()
            return
        }

        searchMlist = mlist.filter({ mousseron -> Bool in
           
            guard let text = searchBar.text
            else
            {
                print("Unable to get filtered text")
                return false
            }
            
            return mousseron.lowercased().contains(text.lowercased())
        })
        
        print(searchMlist)
        clearAll()
        generateDict()
        tableView.reloadData()
    }
    
    //dismisses the searchbar upon press of search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()

    }
    
    //this must be implemented for later features such as separation by genus
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
    
    }
    //alternative for the following uncommented method
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.brown
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let view = view as? UITableViewHeaderFooterView
        {
            view.backgroundView?.backgroundColor = UIColor.init(hexString: "#945200", alpha: 0.77)
            view.textLabel?.textColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 105
    }

    //checks the reset time for the identifier
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
    
    
    //checks to see if user is connected to the internet
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
                
                if let alertPresentationController = alert.popoverPresentationController
                {
                    alertPresentationController.sourceView = self.view
                    alertPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
                
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                print("Valid user session")
                
            }
        
    }
    
    func loadAd()
    {
        //test id
//        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
         interstitial = GADInterstitial(adUnitID: "ca-app-pub-2762075992313293/2176059598")
        
        interstitial.delegate = self
        
        let request = GADRequest()
        
        interstitial.load(request)
        print("ad request loaded")
    }
    
    func runAd()
    {
        
        if interstitial.isReady
        {
            interstitial.present(fromRootViewController: self)
        }
            
        else
        {
            print("Ad wasn't ready")
            performSegue(withIdentifier: "DataBookVCToEntryVC", sender: mushName)

        }
        
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial)
    {
        print("interstitialDidDismissScreen")
        print("Mushname inside ad: \(mushName)")
        
        performSegue(withIdentifier: "DataBookVCToEntryVC", sender: mushName)
    
    }
    

    
//I believe both of these are interchangeable willdisplayheader and willdisplay footer
//    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
//    {
//        if let view = view as? UITableViewHeaderFooterView
//        {
//            view.backgroundView?.backgroundColor = UIColor.brown
//            view.textLabel?.textColor = UIColor.white
//        }
//    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "DataBookVCToEntryVC")
        {
            //sets destination VC to BuyHomeVC
            if let dest = segue.destination as? EntryVC
            {
                //send data of type Home to destination VC
                if let choice = sender as? String
                {
                    dest.fName = choice
                }
            }
            
        }
    }
    

}



extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
