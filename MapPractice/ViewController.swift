//
//  ViewController.swift
//  MapPractice
//
//  Created by Saurav Aryal on 2/27/16.
//  Copyright © 2016 Saurav Aryal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


var searchKey = ""
let GOOGLE_API_KEY = "AIzaSyBSQ11p5somUrlvz7qEtHfS2ulA8Le6xPA"
let delta = 0.02

var latitude = "38.9222"
var longitude = "-77.0194"
var center = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
var baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=500&type=restaurant&name=\(searchKey)&key=\(GOOGLE_API_KEY)"
var region = MKCoordinateRegion(center:center, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))


class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var SearchText: UITextField! // User entered search text
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Ask for Authorisation from the User.
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        SearchText.becomeFirstResponder() //make the keyboard appear
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myspot")
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        annotationView.pinTintColor = UIColor.blueColor()
        
        let button = UIButton(type: .DetailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        
        
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! CustomAnnotation
        let title = location.title
        let subtitle = location.subtitle
        let placeId = location.placeId
//        let alert = UIAlertController(title: title, message: title! + subtitle!, preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil ))
//        presentViewController(alert, animated:true, completion:nil)
      
        performSegueWithIdentifier("godetail", sender: location)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "godetail")
        {
            let vc = segue.destinationViewController as! DetailViewController
            //vc.cafe_titl = (sender as! MKAnnotationView).annotation!
            vc.cafe_title = (sender as? CustomAnnotation)
            
            
        }
    }
    
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        latitude = String(locValue.latitude)
        longitude = String(locValue.longitude)
        center = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        locationManager.stopUpdatingLocation()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: Double(latitude)!,
            longitude: Double(longitude)!
        )
        
        annotate() //call annotate function to make json request and put pins on the map
    }
  
    
 
    
    
    func annotate()
    {
        //in this function we set the map location
        //we start a NSURLsession which allows us to make JSON request
        //we make the JSON request
        //we handle the JSON data
        //we get the longitude and latitude for the location
        //we find the coordinates
        //we put the pin on the map
        
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL)!)
        let task = session.dataTaskWithRequest(request){
            (data, response, error)-> Void in
            if error != nil {
                
                print (error!.localizedDescription)
                return
            }
            //do convert to json
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                
                
                
                if let items = json["results"] as? [[String: AnyObject]]{
                    
                    var all_items:[CustomAnnotation] = [] //array to hold all items to be updated to UI later
                    for items in items{
                        //process items here
                        print (items)
                        
                        if let name = items["name"] as? String, let vicinity = items["vicinity"] as? String, let placeID = items["place_id"]{
                            
                            let coords: [Double] = self.getCoords(items["geometry"] as! Dictionary)
                            
        
                            
                            //let annotation = MKPointAnnotation()
                            
                            
                            let coordinate = CLLocationCoordinate2D(
                                latitude: coords[0],
                                longitude: coords[1]
                            )

                            
//                            annotation.coordinate = CLLocationCoordinate2D(
//                                latitude: coords[0],
//                                longitude: coords[1]
//                            )
//                            annotation.title = name //adding vicinity
//                            annotation.subtitle = vicinity
                            
                            
                            let a = CustomAnnotation(coordinate: coordinate, title: name, subtitle: vicinity, placeId: placeID as! String)
                            all_items.append(a)
                            
                            
                            
                            
                            
                            
                            
                        }
                    }
                    //when finished, update the UI on the main thread
                    dispatch_async(dispatch_get_main_queue()){
                        self.mapView.setRegion(region, animated: true)
                        
                        for a in all_items{
                        self.mapView.addAnnotation(a)
                        }
                    }
                   
                }
                
            }catch{
                //    print("error serializing json: \(error)")
                print("error serializing json")
            }
            
        }
        
        task.resume()
    }
    
    
    
    func getCoords(data: [String:AnyObject]) -> [Double]{
        //we get the coordinates using this function
        let c = data["location"] as![String: AnyObject]
        print (c)
        return [c["lat"] as! Double, c["lng"] as! Double]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // We remove all annotations
        // We get the search key and make the search
        // We put new pins 
        // api call sometimes takes long time, so have patience
        
        self.mapView.removeAnnotations(mapView.annotations)
       
        
        SearchText.resignFirstResponder()
        
        searchKey = SearchText.text!
        baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=500&type=restaurant&name=\(searchKey)&key=\(GOOGLE_API_KEY)"

        
        
        
        annotate()
        
        
        return true
    }
    
   
    
    
    //MARK:- Annotations
    


    
 
//
//
    
    
    
    
    
}

