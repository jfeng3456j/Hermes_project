//
//  labelEditViewController.swift
//  Alarm-ios-swift


import UIKit
import CoreLocation
import MapKit
import Foundation

class LabelEditViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate{
    
    
    @IBOutlet weak var RainPrty: UITextField!
    @IBOutlet weak var SleetPrty: UITextField!
    @IBOutlet weak var SnowPrty: UITextField!
    @IBOutlet weak var WindPrty: UITextField!
    @IBOutlet weak var HeavyPrty: UITextField!
    @IBOutlet weak var MildPrty: UITextField!
    @IBOutlet weak var LowPrty: UITextField!
    
    
    
    var delay, Rain, Snow, Sleet, Wind, Heavy, Mild, Low, locType, locationType,destinationLocation, sourceLocation, strSrcLoc,strDesLoc, maxDelay : String!
    
    
    
    struct GlobalVariable{
        static var srcName = String()
        static var srcCoord = String()
    }
    @IBOutlet weak var coordinateBIndicator: UILabel!
    @IBOutlet weak var smartButton: UIButton!
    @IBOutlet weak var custButton: UIButton!
    
    var segueInfo: SegueInfo!
    
    //variables
    var label: String!
    var locationManager:CLLocationManager!
    var coordinateA: String!
    var coordinateB: String!
    var bPoint = MKPointAnnotation()
    var userLocation:CLLocation!
    
    //currenlocation textfield
    // @IBOutlet weak var currLocation: UITextField!
    @IBOutlet weak var labelTextField: UITextField!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var saveLoadingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LabelEditViewController.GlobalVariable.srcName = strSrcLoc
        LabelEditViewController.GlobalVariable.srcCoord = sourceLocation
        /*
         if (segueInfo.isEditMode){//if we are editing an old alarm, access the old alarm's details data
         
         }else{//default when we are not editing an old alarm
         
         
         }
         */
        
        
        labelTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        self.labelTextField.delegate = self
        
        //self.currLocation.delegate = self
        self.RainPrty.delegate = self
        self.SleetPrty.delegate = self
        self.SnowPrty.delegate = self
        self.WindPrty.delegate = self
        self.HeavyPrty.delegate = self
        self.MildPrty.delegate = self
        self.LowPrty.delegate = self
        
        
        labelTextField.text = label
        RainPrty.text = Rain
        SleetPrty.text = Sleet
        SnowPrty.text = Snow
        WindPrty.text = Wind
        HeavyPrty.text = Heavy
        MildPrty.text = Mild
        LowPrty.text = Low
        
        if (locationType == "smart"){
            smartButton.backgroundColor = UIColor.darkGray
            custButton.backgroundColor = UIColor.clear
            
        }
        if (locationType == "custom"){
            smartButton.backgroundColor = UIColor.clear
            custButton.backgroundColor = UIColor.darkGray
        }
        
        print(strDesLoc)
        
        if ((strDesLoc) != ""){
            
            self.coordinateBIndicator.backgroundColor = UIColor.green
            self.coordinateBIndicator.textColor = UIColor.yellow
            self.coordinateBIndicator.text = "Valid"
            searchBar.text = strDesLoc
        }else{
            coordinateBIndicator.backgroundColor = UIColor.red
            coordinateBIndicator.textColor = UIColor.green
            coordinateBIndicator.text = "Invalid"
        }
        //currLocation.text = "location"
        
        //defined in UITextInputTraits protocol
        labelTextField.returnKeyType = UIReturnKeyType.done
        labelTextField.enablesReturnKeyAutomatically = true
        
        checkSaveBtnStatus()
        
        searchBar.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        saveLoadingIndicator.hidesWhenStopped = true
        
        
        coordinateBIndicator.adjustsFontSizeToFitWidth = true
        coordinateBIndicator.textAlignment = NSTextAlignment.center
        
        
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
        
    }
    
    
    //format weather and traffic textbox to numeric
    
    
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
                //  self.currLocation.text = firstPL?.name;
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
                
                self.destinationLocation = self.coordinateB
                self.strDesLoc = trunc
                
                self.coordinateBIndicator.backgroundColor = UIColor.green
                self.coordinateBIndicator.textColor = UIColor.black
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
        return false
    }
    
    
    
    @IBAction func smartSelect(_ sender: Any) {
        smartButton.backgroundColor = UIColor.darkGray
        custButton.backgroundColor = UIColor.clear
        self.locationType = "smart"
    }
    
    //set location buttons event handler
    @IBAction func custSelect(_ sender: Any) {
        self.locationType = "custom"
        smartButton.backgroundColor = UIColor.clear
        custButton.backgroundColor = UIColor.darkGray
        // Create a standard UIAlertController
        /*
         let alertController = UIAlertController(title: "Enter Location", message: "", preferredStyle: .alert)
         
         // Add a textField to your controller, with a placeholder value & secure entry enabled
         
         alertController.addTextField { textField in
         textField.placeholder = "Enter Current Location"
         textField.textAlignment = .center
         
         }
         
         // A cancel action
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
         print("Canelled")
         }
         
         // This action handles your confirmation action
         let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
         print("Current location value: \(alertController.textFields?.first?.text ?? "None")")
         }
         
         // Add the actions, the order here does not matter
         alertController.addAction(cancelAction)
         alertController.addAction(confirmAction)
         
         // Present to user
         present(alertController, animated: true, completion: nil)
         
         */
    }
    
    //post to php
    @IBAction func clickSave(_ sender: Any) {
        
        self.strSrcLoc = LabelEditViewController.GlobalVariable.srcName
        self.sourceLocation = LabelEditViewController.GlobalVariable.srcCoord
        self.locType = locationType
        
        
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
                    
                    
                    /*
                     DispatchQueue.main.async{
                     //self.destination.text = "Traffice Delay: \(self.delay)"
                     }
                     */
                }
                
                //take in user weather input
                self.Rain = self.RainPrty.text
                self.Sleet = self.SleetPrty.text
                self.Snow = self.SnowPrty.text
                self.Wind = self.WindPrty.text
                
                
                //take in user traffic input
                self.Heavy = self.HeavyPrty.text
                self.Mild = self.MildPrty.text
                self.Low = self.LowPrty.text
                self.findMax()
                
                }.resume()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute:{
                self.label = self.labelTextField.text!
                self.saveLoadingIndicator.stopAnimating()
                self.performSegue(withIdentifier: Id.labelUnwindIdentifier, sender: self)
            })
        }
        
        else{
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        checkSaveBtnStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkSaveBtnStatus()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkSaveBtnStatus()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkSaveBtnStatus()
    }
    
    func checkSaveBtnStatus() {
        
        if (labelTextField.text?.count)! > 0 &&
            (searchBar.text?.count)! > 0 &&
            (RainPrty.text?.count)! > 0 &&
            (SleetPrty.text?.count)! > 0 &&
            (SnowPrty.text?.count)! > 0 &&
            (WindPrty.text?.count)! > 0 &&
            (HeavyPrty.text?.count)! > 0 &&
            (MildPrty.text?.count)! > 0 &&
            (LowPrty.text?.count)! > 0 {
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func findMax () {
        var twDelay: Int
        let weather = max(Rain, Sleet,Snow,Wind)
        let traffic = max(Heavy,Mild,Low)
        
        twDelay =  Int(weather)! + Int(traffic)!
        maxDelay = String(twDelay)
        print("print maxDelay\(maxDelay)")
    }
}











