//
//  labelEditViewController.swift
//  Alarm-ios-swift


import UIKit
import CoreLocation
import MapKit
import Foundation

class LabelEditViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate{
    
    var delay: String!
    var Rain, Snow, Sleet, Wind, Heavy, Mild, Low: String!
    
    @IBOutlet weak var coordinateBIndicator: UILabel!
    
    
  
    
    
    //variables
    var label: String!
    var locationManager:CLLocationManager!
    //
    
    var coordinateA: String!
    var coordinateB: String!
    
    var bPoint = MKPointAnnotation()
    
    var userLocation:CLLocation!
    
    //testing box
    

    
    //currenlocation textfield
    @IBOutlet weak var currLocation: UITextField!
    @IBOutlet weak var labelTextField: UITextField!
    
    
    
    //country UIpicker
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var destination: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.labelTextField.delegate = self
        self.currLocation.delegate = self
        
        labelTextField.text = label
        //currLocation.text = "location"
        
        //defined in UITextInputTraits protocol
        labelTextField.returnKeyType = UIReturnKeyType.done
        labelTextField.enablesReturnKeyAutomatically = true
        
        
        
        searchBar.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        saveLoadingIndicator.hidesWhenStopped = true
      
        coordinateBIndicator.backgroundColor = UIColor.red
        coordinateBIndicator.textColor = UIColor.green
        coordinateBIndicator.text = "Invalid"
        coordinateBIndicator.adjustsFontSizeToFitWidth = true
        coordinateBIndicator.textAlignment = NSTextAlignment.center
        
        
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
        
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        let geoCoder=CLGeocoder();
        geoCoder.reverseGeocodeLocation(userLocation) { (pls: [CLPlacemark]?, error: Error?)  in
            if error == nil {
                print("Successfully set the location")
                guard let plsResult = pls else
                {
                    return
                    
                }
                let firstPL = plsResult.first
                self.currLocation.text = firstPL?.name;
                //self.currLocation.text = String(userLocation.coordinate.longitude) + "," + String(userLocation.coordinate.latitude);
                self.coordinateA = String(userLocation.coordinate.latitude) + "," + String(userLocation.coordinate.longitude);
            }else {
                print("Unable to get the location")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
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
                
                //get coordinates
                ano.coordinate = (placemarks?.location?.coordinate)!
                //ano.title = self.searchBarMap.text!
                //self.destination.text = String(ano.coordinate.longitude) + "," + String(ano.coordinate.latitude)
                
                
                self.coordinateB = String(ano.coordinate.latitude) + "," + String(ano.coordinate.longitude)
                
                
                self.coordinateBIndicator.backgroundColor = UIColor.green
                self.coordinateBIndicator.textColor = UIColor.yellow
                self.coordinateBIndicator.text = "Valid"

            }
            else {
                print (error?.localizedDescription ?? "error")
                self.coordinateBIndicator.backgroundColor = UIColor.red
                self.coordinateBIndicator.textColor = UIColor.green
                self.coordinateBIndicator.text = "Invalid"
            }
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*

*/

        return false
    }
    
    @IBOutlet weak var saveLoadingIndicator: UIActivityIndicatorView!
    
    //post to php
    @IBAction func clickSave(_ sender: Any) {
        if (coordinateB != nil){
        saveLoadingIndicator.startAnimating()
        let url = URL(string: "http://ec2-18-217-212-185.us-east-2.compute.amazonaws.com/~ec2-user/Hermes/getAlarmInfo.php/")!
        let postString = "coordinateA=" + coordinateA + "&coordinateB=" + coordinateB + "&deviceID=374a9s9dfs&alarmNum=alarm2"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: .utf8)
        
        _ = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error1=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                return
            }
            // https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
            if let json = try? JSON(data: data) {
                
                //  print(json["netDelay"].double)
                // print(json["traffic"]["methodOfTrans"].string)
                self.delay = json["netDelay"].stringValue
                print("0:  \(json["netDelay"])")
                
                print("1: \(self.delay)" )
                print("2: \(self.label)" )

                /*
                
                DispatchQueue.main.async{
                    //self.destination.text = "Traffice Delay: \(self.delay)"
                }
 */
            }
            }.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute:{
            self.label = self.labelTextField.text!
            self.saveLoadingIndicator.stopAnimating()
            self.performSegue(withIdentifier: Id.labelUnwindIdentifier, sender: self)
        })
        }else{
            self.label = self.labelTextField.text!
            self.delay = ""
            alertMessage(message: "Invalid Destination! Alarm name is still saved")
        }
    }//end of save buttom
    
    //alert message display
    func alertMessage (message:String) {
        let alert = UIAlertController(title: "Traffic Alert!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default)
        {
            (UIAlertAction) -> Void in
            self.performSegue(withIdentifier: Id.labelUnwindIdentifier, sender: self)
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
        {
            () -> Void in
        }
    }

}










