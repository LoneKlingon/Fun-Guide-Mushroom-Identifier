//
//  PinCell.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-15.
//  Copyright © 2018 AYS. All rights reserved.
//

import UIKit
import MapKit

class PinCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var latitudeLbl: UILabel!
    
    @IBOutlet weak var longtitudeLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    
    var previousLocations = [AnnotationPin]()
    
    var selectedPin: AnnotationPin!
    
    var locationView: UITableView?
    
    @IBAction func deleteBtnPressed(_ sender: Any)
    {
        removePin()
        locationView?.reloadData()
    }
    
    func updateCell(pin: AnnotationPin, tableView: UITableView)
    {
        print("Updating cell")
        titleLbl.text = pin.title
        latitudeLbl.text =  String(describing: pin.coordinate.latitude)
        longtitudeLbl.text =  String(describing: pin.coordinate.longitude)
        dateLbl.text = String(describing: pin.date)
        selectedPin = pin
        locationView = tableView
    }
    
    func removePin()
    {
        MControl.sharedInstance.removeAnnotation(pin: selectedPin)
    }

    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
