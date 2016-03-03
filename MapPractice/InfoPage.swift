//
//  InfoPage.swift
//  MapPractice
//
//  Created by Saurav Aryal on 3/1/16.
//  Copyright © 2016 Saurav Aryal. All rights reserved.
//

import UIKit
import MapKit


class DetailViewController: UIViewController{
    
    @IBOutlet weak var coordinateSet: UILabel!
    @IBOutlet weak var subtitleSet: UILabel!
    @IBOutlet weak var titleSet: UILabel!
    //var cafe_titl: MKAnnotation?
    var cafe_title: CustomAnnotation?
    
    
    override func viewDidLoad() {
        print(cafe_title?.placeId)
        titleSet.text = cafe_title!.title!
        subtitleSet.text = cafe_title!.subtitle!
        coordinateSet.text = String(cafe_title!.coordinate.longitude) + "," + String(cafe_title!.coordinate.latitude)
    }
    

}

