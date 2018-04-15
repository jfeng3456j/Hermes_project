//
//  DetailsController.swift
//  HermesAlarmProject
//
//  Created by Feng-iMac on 4/14/18.
//  Copyright © 2018 LongGames. All rights reserved.
//

import Foundation

import UIKit

class TableViewController: UITableViewController {
    
    struct object {
        var sectionName: String!
        var sectionObject: [String]!
    }
    
    var objectArray = [object] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        objectArray = [object(sectionName: "Alarm Name", sectionObject: ["alarm1",""]),
                       object(sectionName: "Departure Location", sectionObject: ["Current Location","Smart Location", "Custom Location",""]),
                       object(sectionName: "Destination Location", sectionObject: ["Search"]),
                       object(sectionName: "Weather Delay", sectionObject: ["Rain", "Sleet", "Snow", "Wind",""]),
                       object(sectionName: "Traffic Delay", sectionObject: ["Heavy", "Mild", "Low"])
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell!
        cell?.textLabel?.text = objectArray[indexPath.section].sectionObject[indexPath.row]
        return cell!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray[section].sectionObject.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return objectArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectArray[section].sectionName
    }
}

