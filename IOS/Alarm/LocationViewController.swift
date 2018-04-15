//
//  LocationViewController.swift
//  HermesAlarmProject
//
//  Created by Feng-iMac on 4/15/18.
//  Copyright © 2018 LongGames. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Foundation


class LocationViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    var locationManager:CLLocationManager!
    var coordinateA: String!
    var coordinateB: String!
    var bPoint = MKPointAnnotation()
    var userLocation:CLLocation!
    
    var stringCustLoc: String!
    var coordCustLoc: String!
    
    var saved: DarwinBoolean = false
    
    @IBOutlet weak var destinationSearch: UISearchBar!
    
    @IBAction func goBack(_ sender: Any) {
       // _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated:true)
    }
    
    @IBAction func goBackAndSave(_ sender: Any) {
        if (coordCustLoc == nil){
            //pop up box error
            // create the alert
            let alert = UIAlertController(title: "Error", message: "Location cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            saved = false
        }else{
            //send over variables
            // create the alert
            let alert = UIAlertController(title: "Success!", message: "Destination Location set as: \(stringCustLoc)", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true,  completion: {
                sleep(2)
                self.dismiss(animated:true, completion: {
                    self.dismiss(animated: true)
                })
                
            })
            saved = true
            //(() -> Void)?
            /*
            self.dismiss(animated: true, completion: {
                self.dismiss(animated:true)
            })
 */
          //  self.dismiss(animated:true)
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
         destinationSearch.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("View Appeared")
        if ((saved).boolValue){
            self.dismiss(animated:true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("View Will Appear")
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    
    //search for destination coordinates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.becomeFirstResponder()
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchBar.text!) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                let placemarks = placemarks?.first
                //let ano = MKPointAnnotation()
                
                let ano  = self.bPoint
                //Change the text that the user inputted to a better formatted one
                var corrText = ""
                
                if (placemarks?.name != nil){
                    corrText += "\((placemarks?.name)!), "
                }
                
                if (placemarks?.subThoroughfare != nil){
                    corrText += "\((placemarks?.subThoroughfare)!), "
                }
                
                if (placemarks?.thoroughfare != nil){
                    corrText += "\((placemarks?.thoroughfare)!), "
                }
                if (placemarks?.locality != nil){
                    corrText += "\((placemarks?.locality)!), "
                }
                if (placemarks?.administrativeArea != nil){
                    corrText += "\((placemarks?.administrativeArea)!), "
                }
                if (placemarks?.country != nil){
                    corrText += "\((placemarks?.country)!), "
                }
                if (placemarks?.postalCode != nil){
                    corrText += "\((placemarks?.postalCode)!), "
                }
                
                
                
                let trunc = String(corrText.characters.dropLast(2))
                
                
                searchBar.text = trunc
                
                //get coordinates
                ano.coordinate = (placemarks?.location?.coordinate)!
                //ano.title = self.searchBarMap.text!
                //self.destination.text = String(ano.coordinate.longitude) + "," + String(ano.coordinate.latitude)
                
                
                self.coordinateB = String(ano.coordinate.latitude) + "," + String(ano.coordinate.longitude)
                self.stringCustLoc = trunc
                self.coordCustLoc = self.coordinateB
            
            }
            
        }
    }
        
        
}
