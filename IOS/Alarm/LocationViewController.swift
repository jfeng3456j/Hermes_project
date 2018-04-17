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
    
    
   
    @IBOutlet weak var locIndicator: UILabel!
    var coordinateB: String!
    var bPoint = MKPointAnnotation()
    var userLocation:CLLocation!
    var strSrcLoc: String!
    var sourceLocation: String!
    
    var saved: DarwinBoolean = false
    
    @IBOutlet weak var destinationSearch: UISearchBar!
    
    @IBAction func goBack(_ sender: Any) {
       // _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated:true)
    }
    
    @IBAction func goBackAndSave(_ sender: Any) {
        if (sourceLocation == nil){
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
            let alert = UIAlertController(title: "Success!", message: "Source Location set as: \(strSrcLoc)", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true,  completion: {
                
                sleep(2)
                self.dismiss(animated:true, completion: {
                    LabelEditViewController.GlobalVariable.srcName = self.strSrcLoc
                    LabelEditViewController.GlobalVariable.srcCoord = self.sourceLocation
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
    

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("View Appeared")
        if ((saved).boolValue){
            self.dismiss(animated:true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Loaded")
        destinationSearch.delegate = self
        destinationSearch.text = LabelEditViewController.GlobalVariable.srcName
        
        
        if ((strSrcLoc) != ""){
            
            self.locIndicator.backgroundColor = UIColor.green
            self.locIndicator.textColor = UIColor.yellow
            self.locIndicator.text = "Valid"
            destinationSearch.text = strSrcLoc
            
        }else{
            
            locIndicator.backgroundColor = UIColor.red
            locIndicator.textColor = UIColor.green
            locIndicator.text = "Invalid"
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
                self.coordinateB = String(ano.coordinate.latitude) + "," + String(ano.coordinate.longitude)
                self.strSrcLoc = trunc
                self.sourceLocation = self.coordinateB
                self.locIndicator.backgroundColor = UIColor.green
                self.locIndicator.textColor = UIColor.black
                self.locIndicator.text = "Valid"
            
            }
            else {
                print (error?.localizedDescription ?? "error")
                self.locIndicator.backgroundColor = UIColor.red
                self.locIndicator.textColor = UIColor.green
                self.locIndicator.text = "Invalid"
        }
    }
        
        
}
}
