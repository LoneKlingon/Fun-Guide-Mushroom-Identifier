//
//  AnnotationPin.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-06-09.
//  Copyright © 2018 AYS. All rights reserved.
//
import MapKit

class AnnotationPin: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var date: Date?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D)
    {
        //equivalent this.var in java
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
