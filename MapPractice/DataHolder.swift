//
//  DataHolder.swift
//  MapPractice
//
//  Created by Saurav Aryal on 2/25/16.
//  Copyright © 2016 Saurav Aryal. All rights reserved.
//

import MapKit
import UIKit

class CustomAnnotation: NSObject, MKAnnotation{
    
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let placeId: String
    
    
    
    init (coordinate:CLLocationCoordinate2D, title:NSString, subtitle:NSString, placeId:String){
        self.title = title as String
        self.subtitle = subtitle as String
        self.coordinate=coordinate
        self.placeId = placeId
        
        
        super.init()
        
       
        
    }
}