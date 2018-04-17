//
//  AlarmAddViewController.swift
//  Alarm-ios-swift


import UIKit
import Foundation
import MediaPlayer

class AlarmAddEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var locSet: Bool = false
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    var noTWLabel = ""
    
    var alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()
    var segueInfo: SegueInfo!
    var snoozeEnabled: Bool = false
    
    var enabled: Bool!
    
    //traffic weather var
    var autoTW: Bool!
    
    //isEditMode
    var isEditMode: Bool = false
    
    override func viewDidLoad() {
        self.isEditMode =  segueInfo.isEditMode
        
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alarmModel=Alarms()
        tableView.reloadData()
        snoozeEnabled = segueInfo.snoozeEnabled
        autoTW = segueInfo.autoTW
        
        
        
        if ((segueInfo.delay != nil) && (segueInfo.delay != "")  ){
            //var convertedTime = getNumberFrom(string: segueInfo.delay)
            
            //3965 sec
            //divide int 60 -> 6 minutes
            //(3965 % 3600) -> 365 sec      ----> 365 /60 -> minutes
            //
            var convertedAllTimeSec  = Int(segueInfo.delay)
            var convertedTimeMinutes = (convertedAllTimeSec!%3600)/60
            var convertedTimeHours = (convertedAllTimeSec)!/3600
            
            /*alertMessage (message: "Traffic and Weather Delays Expected: \(convertedTimeHours) hours \(convertedTimeMinutes) minutes")*/
        }
        
        
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveEditAlarm(_ sender: AnyObject) {
        //set the alarm time from UIDatePicker
        
        let date = Scheduler.correctSecondComponent(date: datePicker.date)
        //let date:Date=self.datePicker.date;
        let index = segueInfo.curCellIndex
        var tempAlarm = Alarm()
        tempAlarm.date = date
        tempAlarm.label = segueInfo.label
        tempAlarm.enabled = true
        tempAlarm.mediaLabel = segueInfo.mediaLabel
        tempAlarm.mediaID = segueInfo.mediaID
        tempAlarm.snoozeEnabled = snoozeEnabled
        tempAlarm.repeatWeekdays = segueInfo.repeatWeekdays
        tempAlarm.uuid = UUID().uuidString
        tempAlarm.onSnooze = false
        
        tempAlarm.delay = segueInfo.delay
        tempAlarm.autoTW = segueInfo.autoTW
        tempAlarm.Rain = segueInfo.Rain
        tempAlarm.Snow = segueInfo.Snow
        tempAlarm.Sleet = segueInfo.Sleet
        tempAlarm.Wind = segueInfo.Wind
        tempAlarm.Heavy = segueInfo.Heavy
        tempAlarm.Mild = segueInfo.Mild
        tempAlarm.Low = segueInfo.Low
        tempAlarm.trafficStatus = segueInfo.trafficStatus
        tempAlarm.weatherStatus = segueInfo.weatherStatus
        tempAlarm.destinationLocation = segueInfo.destinationLocation
        tempAlarm.sourceLocation = segueInfo.sourceLocation
        tempAlarm.locType = segueInfo.locType
        tempAlarm.strDesLoc = segueInfo.strDesLoc
        tempAlarm.strSrcLoc = segueInfo.strSrcLoc
        tempAlarm.maxDelay = segueInfo.maxDelay
        
        
        //if user just wants a regular alarm with only a name
        if (autoTW == false)
        {
            tempAlarm.label = self.noTWLabel
        }
        
        if segueInfo.isEditMode {
            alarmModel.alarms[index] = tempAlarm
            
        }
        else {
            
            
            alarmModel.alarms.append(tempAlarm)
            
        }
        self.performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        if segueInfo.isEditMode {
            return 2
        }
        else {
            return 1
        }
    }
    
    //number of row in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //return 4
            return 5
        }
        else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.settingIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: Id.settingIdentifier)
        }
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                cell!.textLabel!.text = "Repeat"
                cell!.detailTextLabel!.text = WeekdaysViewController.repeatText(weekdays: segueInfo.repeatWeekdays)
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 1 {
                cell!.textLabel!.text = "Automatic Traffic/Weather Delays"
                
                let sw = UISwitch(frame: CGRect())
               
                sw.addTarget(self, action: #selector(AlarmAddEditViewController.trafficWeatherTap(_:)), for: UIControlEvents.touchUpInside)
                
                if autoTW {
                    sw.setOn(true, animated: false)
                }
                
                cell!.accessoryView = sw
                
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
                
                
            else if indexPath.row == 2 {
                cell!.textLabel!.text = "Details"
                cell!.detailTextLabel!.text = segueInfo.label
                self.noTWLabel = cell!.detailTextLabel!.text!
                
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 3 {
                cell!.textLabel!.text = "Sound"
                cell!.detailTextLabel!.text = segueInfo.mediaLabel
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            else if indexPath.row == 4 {
                
                cell!.textLabel!.text = "Snooze"
                let sw = UISwitch(frame: CGRect())
                sw.addTarget(self, action: #selector(AlarmAddEditViewController.snoozeSwitchTapped(_:)), for: UIControlEvents.touchUpInside)
                
                if snoozeEnabled {
                    sw.setOn(true, animated: false)
                }
                
                cell!.accessoryView = sw
            }
        }
        else if indexPath.section == 1 {
            cell = UITableViewCell(
                style: UITableViewCellStyle.default, reuseIdentifier: Id.settingIdentifier)
            cell!.textLabel!.text = "Delete Alarm"
            cell!.textLabel!.textAlignment = .center
            cell!.textLabel!.textColor = UIColor.red
        }
        
        return cell!
    }
    
    //this is the performSegue (links to different UI)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                performSegue(withIdentifier: Id.weekdaysSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            case 2:
                if (autoTW){
                    performSegue(withIdentifier: Id.labelSegueIdentifier, sender: self)
                    cell?.setSelected(true, animated: false)
                    cell?.setSelected(false, animated: false)
                }else{
                    //Prompt User for information if the user does not want to have Traffic and weather
                    let alertController = UIAlertController(title: "Enter Alarm Name", message: "", preferredStyle: .alert)
                    
                    // Add a textField to your controller, with a placeholder value & secure entry enabled
                    
                    alertController.addTextField { textField in
                        textField.placeholder = "Alarm"
                        textField.textAlignment = .center
                    }
                    
                    // A cancel action
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                        print("Canelled")
                    }
                    
                    // This action handles your confirmation action
                    let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
                        if (alertController.textFields?.first?.text != ""){
                            //if text is good
                            print("Current location value: \(alertController.textFields?.first?.text ?? "None")")
                            cell!.detailTextLabel!.text = alertController.textFields?.first?.text
                            self.noTWLabel = (alertController.textFields?.first?.text)!
                            print("noTWLabel: \(self.noTWLabel)")
                        }else{
                            let alert = UIAlertController(title: "Error", message: "Name is null", preferredStyle: UIAlertControllerStyle.alert)
                            
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    // Add the actions, the order here does not matter
                    alertController.addAction(cancelAction)
                    alertController.addAction(confirmAction)
                    
                    // Present to user
                    present(alertController, animated: true, completion: nil)
                    
                    cell?.setSelected(true, animated: false)
                    cell?.setSelected(false, animated: false)
                }
            case 3:
                performSegue(withIdentifier: Id.soundSegueIdentifier, sender: self)
                cell?.setSelected(true, animated: false)
                cell?.setSelected(false, animated: false)
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            //delete alarm
            alarmModel.alarms.remove(at: segueInfo.curCellIndex)
            performSegue(withIdentifier: Id.saveSegueIdentifier, sender: self)
        }
        
    }
    
    @IBAction func snoozeSwitchTapped (_ sender: UISwitch) {
        snoozeEnabled = sender.isOn
    }
    
    @IBAction func trafficWeatherTap (_ sender: UISwitch) {
        autoTW = sender.isOn
        autoTW = true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == Id.saveSegueIdentifier {
            let dist = segue.destination as! MainAlarmViewController
            let cells = dist.tableView.visibleCells
            for cell in cells {
                let sw = cell.accessoryView as! UISwitch
                if sw.tag > segueInfo.curCellIndex
                {
                    sw.tag -= 1
                }
            }
            alarmScheduler.reSchedule()
        }
        else if segue.identifier == Id.soundSegueIdentifier {
            //TODO
            let dist = segue.destination as! MediaViewController
            dist.mediaID = segueInfo.mediaID
            dist.mediaLabel = segueInfo.mediaLabel
        }
        else if segue.identifier == Id.labelSegueIdentifier {
            let dist = segue.destination as! LabelEditViewController
            dist.label = segueInfo.label
            dist.delay = segueInfo.delay
            dist.AutoTW = segueInfo.autoTW
        
            //names
            dist.strDesLoc = segueInfo.strDesLoc
            dist.strSrcLoc = segueInfo.strSrcLoc
            
            //coordinates
            dist.destinationLocation = segueInfo.destinationLocation
            dist.sourceLocation = segueInfo.sourceLocation
            
            //locType
            dist.locType = segueInfo.locType
            
            //Weather Conditions
            dist.Rain = segueInfo.Rain
            dist.Sleet = segueInfo.Sleet
            dist.Snow = segueInfo.Snow
            dist.Wind = segueInfo.Wind
            
            //Traffic
            dist.Heavy = segueInfo.Heavy
            dist.Mild = segueInfo.Mild
            dist.Low = segueInfo.Low
            dist.maxDelay = segueInfo.maxDelay
            
            
        }
        else if segue.identifier == Id.weekdaysSegueIdentifier {
            let dist = segue.destination as! WeekdaysViewController
            dist.weekdays = segueInfo.repeatWeekdays
        }
    }
    
    @IBAction func unwindFromLabelEditView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! LabelEditViewController
        segueInfo.label = src.label
        segueInfo.delay = src.delay
        segueInfo.autoTW = src.AutoTW
        
        segueInfo.strDesLoc = src.strDesLoc
        segueInfo.strSrcLoc = src.strSrcLoc
        
        segueInfo.destinationLocation = src.destinationLocation
        segueInfo.sourceLocation = src.sourceLocation
        
        segueInfo.locType = src.locType
        
        segueInfo.Rain = src.Rain
        segueInfo.Snow = src.Snow
        segueInfo.Wind = src.Wind
        segueInfo.Sleet = src.Sleet
        
        segueInfo.Heavy = src.Heavy
        segueInfo.Mild = src.Mild
        
        
        segueInfo.Low = src.Low
        segueInfo.maxDelay = src.maxDelay
        
    }
    
    @IBAction func unwindFromWeekdaysView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! WeekdaysViewController
        segueInfo.repeatWeekdays = src.weekdays
    }
    
    @IBAction func unwindFromMediaView(_ segue: UIStoryboardSegue) {
        let src = segue.source as! MediaViewController
        segueInfo.mediaLabel = src.mediaLabel
        segueInfo.mediaID = src.mediaID
    }
    
    //alert message
    func alertMessage (message:String) {
        let alert = UIAlertController(title: "Traffic Alert!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default)
        {
            (UIAlertAction) -> Void in
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
        {
            () -> Void in
        }
    }
    
    
    
}
