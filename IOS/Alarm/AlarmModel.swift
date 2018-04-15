//
//  AlarmModel.swift
//  Alarm-ios-swift


import Foundation
import MediaPlayer

struct Alarm: PropertyReflectable {
    var date: Date = Date()
    var enabled: Bool = false
    var snoozeEnabled: Bool = false
    var repeatWeekdays: [Int] = []
    var uuid: String = ""
    var mediaID: String = ""
    var mediaLabel: String = "bell"
    var label: String = "Alarm"
    var onSnooze: Bool = false
    
    var delay: String = ""
    var autoTW: Bool = false
    var Rain: String = ""
    var Snow: String = ""
    var Sleet: String = ""
    var Wind: String = ""
    var Heavy: String = ""
    var Mild: String = ""
    var Low: String = ""
    var trafficStatus: String = ""
    var weatherStatus: String = ""
    var destinationLocation: String = ""
    var sourceLocation: String = ""
    var locType: String = ""
    var maxDelay: String = ""
    var midDelay: String = ""
    
    
    
    init(){}
    
    init(date:Date, enabled:Bool, snoozeEnabled:Bool, repeatWeekdays:[Int], uuid:String, mediaID:String, mediaLabel:String, label:String, onSnooze: Bool, delay: String, autoTW: Bool, Rain: String, Snow: String, Sleet: String, Wind: String, Heavy: String, Mild: String, Low: String, trafficStatus: String, weatherStatus: String, destinationLocation: String, sourceLocation: String, locType: String)  {
        self.date = date
        self.enabled = enabled
        self.snoozeEnabled = snoozeEnabled
        self.repeatWeekdays = repeatWeekdays
        self.uuid = uuid
        self.mediaID = mediaID
        self.mediaLabel = mediaLabel
        self.label = label
        self.onSnooze = onSnooze
        
        self.delay = delay
        self.autoTW = autoTW
        self.Rain = Rain
        self.Snow = Snow
        self.Sleet = Sleet
        self.Wind = Wind
        self.Heavy = Heavy
        self.Mild = Mild
        self.Low = Low
        self.trafficStatus = trafficStatus
        self.weatherStatus = weatherStatus
        self.destinationLocation = destinationLocation
        self.sourceLocation = sourceLocation
        self.locType = locType
        
        
    }
    
    init(_ dict: PropertyReflectable.RepresentationType){
        date = dict["date"] as! Date
        enabled = dict["enabled"] as! Bool
        snoozeEnabled = dict["snoozeEnabled"] as! Bool
        repeatWeekdays = dict["repeatWeekdays"] as! [Int]
        uuid = dict["uuid"] as! String
        mediaID = dict["mediaID"] as! String
        mediaLabel = dict["mediaLabel"] as! String
        label = dict["label"] as! String
        onSnooze = dict["onSnooze"] as! Bool
        
        delay = dict["delay"] as! String
        autoTW  = dict["autoTW"] as! Bool
        Rain = dict ["Rain"] as! String
        Snow = dict ["Snow"] as! String
        Sleet = dict ["Sleet"] as! String
        Wind = dict ["Wind"] as! String
        Heavy = dict ["Heavy"] as! String
        Mild = dict ["Mild"] as! String
        trafficStatus = dict ["trafficStatus"] as! String
        weatherStatus = dict ["weatherStatus"] as! String
        destinationLocation = dict ["destinationLocation"] as! String
        sourceLocation = dict ["sourceLocation"] as! String
        locType = dict ["locType"] as! String
        maxDelay = dict ["maxDelay"] as! String
        midDelay = dict["midDelay"] as! String
        
        
    }
    //Update this incase you forget 
    static var propertyCount: Int = 25
}

//format alarm time to 12 hour format
extension Alarm {
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self.date)
    }
}

//This can be considered as a viewModel
class Alarms: Persistable {
    let ud: UserDefaults = UserDefaults.standard
    let persistKey: String = "myAlarmKey"
    var alarms: [Alarm] = [] {
        //observer, sync with UserDefaults
        didSet{
            persist()
        }
    }
    
    private func getAlarmsDictRepresentation()->[PropertyReflectable.RepresentationType] {
        return alarms.map {$0.propertyDictRepresentation}
    }
    
    init() {
        alarms = getAlarms()
    }
    
    func persist() {
        ud.set(getAlarmsDictRepresentation(), forKey: persistKey)
        ud.synchronize()
    }
    
    func unpersist() {
        for key in ud.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
    }
    
    var count: Int {
        return alarms.count
    }
    
    //helper, get all alarms from Userdefaults
    private func getAlarms() -> [Alarm] {
        let array = UserDefaults.standard.array(forKey: persistKey)
        guard let alarmArray = array else{
            return [Alarm]()
        }
        if let dicts = alarmArray as? [PropertyReflectable.RepresentationType]{
            if dicts.first?.count == Alarm.propertyCount {
                return dicts.map{Alarm($0)}
            }
        }
        unpersist()
        return [Alarm]()
    }
}
