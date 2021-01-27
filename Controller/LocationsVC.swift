//
//  LocationsVC.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-15.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import MapKit

class LocationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var savedLocations = [AnnotationPin]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var locationsSegment: UISegmentedControl!
    
    @IBAction func locationsSegmentPressed(_ sender: Any)
    {
        if (locationsSegment.selectedSegmentIndex == 0)
        {
            //performSegue(withIdentifier: "LocationsVCToMapVC", sender: nil)
            dismiss(animated: false, completion: nil)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PinCell") as? PinCell
        {
            cell.updateCell(pin: savedLocations[indexPath.row], tableView: tableView)
            return cell
        }
    
        return PinCell()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return savedLocations.count
    }
    
    func loadAnnotations()
    {
        let locations = MControl.sharedInstance.loadAnnotations()
        
        for location in locations
        {
            print("Inside Location VC")
            print("Location: \(location)")
            var latitude = location["lat"] as? CLLocationDegrees
            var longtitude = location["long"] as? CLLocationDegrees
            var coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longtitude!)
            print("Coord: \(coordinate)")
            var title = location["title"] as? String
            print("Coord: \(title)")
            var date = location["date"] as? Date
            var oldPin = AnnotationPin(title: title!, subtitle: "", coordinate: coordinate)
            oldPin.date = date
            print("Date: \(date)")
            
            print("oldpin: \(oldPin)")
            
            savedLocations.append(oldPin)
            
        }
        print("SavedLocations count: \(savedLocations.count)")
        tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        loadAnnotations()
        
        
        locationsSegment.selectedSegmentIndex = 1
        locationsSegment.isSelected = true

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
        
        if (segue.identifier == "LocationsVCToMapVC")
        {
            
            if let dest = segue.destination as? MapVC
            {
                
            }
            
        }
        
        
    }
 

}
