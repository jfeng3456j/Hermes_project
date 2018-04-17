//
//  Scheduler.swift
//  Alarm-ios-swift
//
//

import Foundation
import UIKit


class Scheduler : AlarmSchedulerDelegate
{
    
    
    var alarmModel: Alarms = Alarms()
    func setupNotificationSettings() -> UIUserNotificationSettings {
        
        
        var snoozeEnabled: Bool = false
        if let n = UIApplication.shared.scheduledLocalNotifications {
            if let result = minFireDateWithIndex(notifications: n) {
                let i = result.1
                snoozeEnabled = alarmModel.alarms[i].snoozeEnabled
            }
        }
        // Specify the notification types.
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound]
        
        // Specify the notification actions.
        let stopAction = UIMutableUserNotificationAction()
        stopAction.identifier = Id.stopIdentifier
        stopAction.title = "OK"
        stopAction.activationMode = UIUserNotificationActivationMode.background
        stopAction.isDestructive = false
        stopAction.isAuthenticationRequired = false
        
        let snoozeAction = UIMutableUserNotificationAction()
        snoozeAction.identifier = Id.snoozeIdentifier
        snoozeAction.title = "Snooze"
        snoozeAction.activationMode = UIUserNotificationActivationMode.background
        snoozeAction.isDestructive = false
        snoozeAction.isAuthenticationRequired = false
        
        let actionsArray = snoozeEnabled ? [UIUserNotificationAction](arrayLiteral: snoozeAction, stopAction) : [UIUserNotificationAction](arrayLiteral: stopAction)
        let actionsArrayMinimal = snoozeEnabled ? [UIUserNotificationAction](arrayLiteral: snoozeAction, stopAction) : [UIUserNotificationAction](arrayLiteral: stopAction)
        // Specify the category related to the above actions.
        let alarmCategory = UIMutableUserNotificationCategory()
        alarmCategory.identifier = "myAlarmCategory"
        alarmCategory.setActions(actionsArray, for: .default)
        alarmCategory.setActions(actionsArrayMinimal, for: .minimal)
        
        
        let categoriesForSettings = Set(arrayLiteral: alarmCategory)
        // Register the notification settings.
        let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: categoriesForSettings)
        UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
        return newNotificationSettings
    }
    
    private func correctDate(_ date: Date, onWeekdaysForNotify weekdays:[Int]) -> [Date]
    {
       
        //seting the date
        var correctedDate: [Date] = [Date]()
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let flags: NSCalendar.Unit = [NSCalendar.Unit.weekday, NSCalendar.Unit.weekdayOrdinal, NSCalendar.Unit.day]
        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
        let weekday:Int = dateComponents.weekday!
        

        //no repeat
        if weekdays.isEmpty{
            //scheduling date is eariler than current date
            if date < now {
                //plus one day, otherwise the notification will be fired righton
                correctedDate.append((calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: 1, to: date, options:.matchStrictly)!)
            }
            else { //later
                correctedDate.append(date)
            }
            return correctedDate
        }
        //repeat days
        else {
            let daysInWeek = 7
            correctedDate.removeAll(keepingCapacity: true)
            for wd in weekdays {
                
                var wdDate: Date!
                //schedule on next week
                if compare(weekday: wd, with: weekday) == .before {
                    wdDate =  (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd+daysInWeek-weekday, to: date, options:.matchStrictly)!
                }
                //schedule on today or next week
                else if compare(weekday: wd, with: weekday) == .same {
                    //scheduling date is eariler than current date, then schedule on next week
                    if date.compare(now) == ComparisonResult.orderedAscending {
                        wdDate = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: daysInWeek, to: date, options:.matchStrictly)!
                    }
                    else { //later
                        wdDate = date
                    }
                }
                //schedule on next days of this week
                else { //after
                    wdDate =  (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: wd-weekday, to: date, options:.matchStrictly)!
                }
                
                //fix second component to 0
                wdDate = Scheduler.correctSecondComponent(date: wdDate, calendar: calendar)
                correctedDate.append(wdDate)
            }
             print("Inside correcteDate:  \(correctedDate)")
            return correctedDate
        }
    }
    
    public static func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian))->Date {
        //second to alarm time
        
        
        let second = calendar.component(.second, from: date)
        
        let d = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: -second, to: date, options:.matchStrictly)!
        return d
    }

    //autoTW set alarm func
    internal func setNotificationWithDate(_ date: Date, onWeekdaysForNotify weekdays:[Int], snoozeEnabled:Bool,  onSnooze: Bool, soundName: String, index: Int, maxDelay: Int, Rain: Int, Snow: Int, Sleet: Int, Wind: Int, Heavy: Int, Mild: Int, Low: Int, AutoTW: Bool, sourceLocation: String, destinationLocation: String) {
        
        print("!!!!!!!!!!!!!!!!!: \(date) !!!!!!!!!!!!!!!!!!")
        print("!!!!!!!!!!!!!!!!!Low time: \(date.addingTimeInterval(TimeInterval(Low*60))) !!!!!!!!!!!!!!!!!!")
        print("!!!!!!!!!!!!!!!!!Rain time: \(date.addingTimeInterval(TimeInterval(Rain*60))) !!!!!!!!!!!!!!!!!!")
        
        var origDate = date
    
        var date = date.addingTimeInterval(TimeInterval(-maxDelay*60))
       
        var currDate = Date()
        
        if (currDate > date ){
            print("currDate is less then date")
            date = currDate.addingTimeInterval(TimeInterval(1))
            origDate = currDate.addingTimeInterval(TimeInterval(1))
        }
        
        let AlarmNotification: UILocalNotification = UILocalNotification()
        AlarmNotification.alertBody = "Wake Up!"
        AlarmNotification.alertAction = "Open App"
        AlarmNotification.category = "myAlarmCategory"
        AlarmNotification.soundName = soundName + ".mp3"
        AlarmNotification.timeZone = TimeZone.current
        let repeating: Bool = !weekdays.isEmpty
        //Major Key
        if (AutoTW){
            AlarmNotification.userInfo = ["snooze" : snoozeEnabled, "index": index, "soundName": soundName, "repeating" : repeating, "Sleet" : Sleet, "Wind" : Wind, "Snow" : Snow,  "Rain" : Rain,"Heavy" : Heavy, "Mild" : Mild, "Low" : Low, "sourceLocation" : sourceLocation, "destinationLocation" : destinationLocation, "origDate" : origDate, "AutoTW" : AutoTW]
        }else{
            //noAutoTW
            AlarmNotification.userInfo = ["snooze" : snoozeEnabled, "index": index, "soundName": soundName, "repeating" : repeating, "Sleet" : 0, "Wind" : 0, "Snow" : 0,  "Rain" : 0,"Heavy" : 0, "Mild" : 0, "Low" : 0, "sourceLocation" : "0,0", "destinationLocation" : "0,0", "origDate" : origDate, "AutoTW" : AutoTW]
        }
        //repeat weekly if repeat weekdays are selected
        //no repeat with snooze notification
        if !weekdays.isEmpty && !onSnooze{
            AlarmNotification.repeatInterval = NSCalendar.Unit.weekOfYear
        }
        
        let datesForNotification = correctDate(date, onWeekdaysForNotify:weekdays)
        
        syncAlarmModel()
        for d in datesForNotification {
            
            if onSnooze {
                alarmModel.alarms[index].date = Scheduler.correctSecondComponent(date: alarmModel.alarms[index].date)
            }
            else {
                alarmModel.alarms[index].date = origDate
            }
            AlarmNotification.fireDate = d
            UIApplication.shared.scheduleLocalNotification(AlarmNotification)
        }
        setupNotificationSettings()
            
        
    }
    
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let now = Date()
        let snoozeTime = (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: snoozeMinute, to: now, options:.matchStrictly)!
        
        //need to make a change here

        setNotificationWithDate(snoozeTime, onWeekdaysForNotify: [Int](), snoozeEnabled: true, onSnooze:true, soundName: soundName, index: index, maxDelay: 0, Rain: 0, Snow: 0, Sleet: 0, Wind: 0, Heavy: 0, Mild: 0, Low: 0, AutoTW: false, sourceLocation: "null", destinationLocation: "null" )
    }
    
    func reSchedule() {
        //Major Key Alert?
        //cancel all and register all is often more convenient
        UIApplication.shared.cancelAllLocalNotifications()
        syncAlarmModel()
        for i in 0..<alarmModel.count{
            let alarm = alarmModel.alarms[i]
            if alarm.enabled {
                //change here
                if(alarm.autoTW){
                    setNotificationWithDate(alarm.date as Date, onWeekdaysForNotify: alarm.repeatWeekdays, snoozeEnabled: alarm.snoozeEnabled, onSnooze: false, soundName: alarm.mediaLabel, index: i, maxDelay: Int(alarm.maxDelay)!, Rain: Int(alarm.Rain)!, Snow: Int(alarm.Snow)!, Sleet: Int(alarm.Sleet)!, Wind: Int(alarm.Wind)!, Heavy: Int(alarm.Heavy)!, Mild: Int(alarm.Mild)!, Low: Int(alarm.Low)!, AutoTW: alarm.autoTW, sourceLocation: alarm.sourceLocation, destinationLocation: alarm.destinationLocation)
                }else{
                                        setNotificationWithDate(alarm.date as Date, onWeekdaysForNotify: alarm.repeatWeekdays, snoozeEnabled: alarm.snoozeEnabled, onSnooze: false, soundName: alarm.mediaLabel, index: i, maxDelay: 0, Rain: 0, Snow: 0, Sleet: 0, Wind: 0, Heavy: 0, Mild: 0, Low: 0, AutoTW: alarm.autoTW, sourceLocation: "0,0", destinationLocation: "0,0")
                }
            }
        }
    }
    
    // workaround for some situation that alarm model is not setting properly (when app on background or not launched)
    func checkNotification() {
        alarmModel = Alarms()
        let notifications = UIApplication.shared.scheduledLocalNotifications
        if notifications!.isEmpty {
            for i in 0..<alarmModel.count {
                alarmModel.alarms[i].enabled = false
            }
        }
        else {
            for (i, alarm) in alarmModel.alarms.enumerated() {
                var isOutDated = true
                if alarm.onSnooze {
                    isOutDated = false
                }
                for n in notifications! {
                    if alarm.date >= n.fireDate! {
                        isOutDated = false
                    }
                }
                if isOutDated {
                    alarmModel.alarms[i].enabled = false
                }
            }
        }
    }
    
    private func syncAlarmModel() {
        alarmModel = Alarms()
    }
    
    private enum weekdaysComparisonResult {
        case before
        case same
        case after
    }
    
    private func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult
    {
        if w1 != 1 && w2 == 1 {return .before}
        else if w1 == w2 {return .same}
        else {return .after}
    }
    
    private func minFireDateWithIndex(notifications: [UILocalNotification]) -> (Date, Int)? {
        if notifications.isEmpty {
            return nil
        }
        var minIndex = -1
        var minDate: Date = notifications.first!.fireDate!
        for n in notifications {
            let index = n.userInfo!["index"] as! Int
            if(n.fireDate! <= minDate) {
                minDate = n.fireDate!
                minIndex = index
            }
        }
        return (minDate, minIndex)
    }
}
