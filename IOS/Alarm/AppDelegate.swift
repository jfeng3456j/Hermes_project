//
//  AppDelegate.swift
//  WeatherAlarm
//
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate, AlarmApplicationDelegate{
    var difference: Int = 0
    var window: UIWindow?
    var audioPlayer: AVAudioPlayer?
    let alarmScheduler: AlarmSchedulerDelegate = Scheduler()
    var alarmModel: Alarms = Alarms()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError{
            error = error1
            print("could not set session. err:\(error!.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError{
            error = error1
            print("could not active session. err:\(error!.localizedDescription)")
        }
        window?.tintColor = UIColor.red
        
        return true
    }
   
    //receive local notification when app in foreground -alert notification
    //**************** alarms goes off
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        //show an alert when the alarms goes off
        let storageController = UIAlertController(title: "Alarm", message: "Time is up!", preferredStyle: .alert)
        var isSnooze: Bool = false
        var soundName: String = ""
        var index: Int = -1
        
        var Sleet: Int = 0
        var Wind: Int = 0
        var Snow: Int = 0
        var Rain: Int = 0
        
        var Heavy: Int = 0
        var Mild: Int = 0
        var Low: Int = 0
        
        var sourceLocation: String = ""
        var destinationLocation: String = ""
        
        var origDate: Date = Date()
        
        if let userInfo = notification.userInfo {
            isSnooze = userInfo["snooze"] as! Bool
            soundName = userInfo["soundName"] as! String
            index = userInfo["index"] as! Int
            
            Sleet = userInfo["Sleet"] as! Int
            Wind = userInfo["Wind"] as! Int
            Snow = userInfo["Snow"] as! Int
            Rain = userInfo["Rain"] as! Int
            
            Heavy = userInfo["Heavy"] as! Int
            Mild = userInfo["Mild"] as! Int
            Low = userInfo["Low"] as! Int
            
            sourceLocation = userInfo["sourceLocation"] as! String
            destinationLocation = userInfo["destinationLocation"] as! String
            
            origDate = userInfo["origDate"] as! Date
        }

        
        var coordinateA = sourceLocation
        var coordinateB = destinationLocation
        let url = URL(string: "http://ec2-18-217-212-185.us-east-2.compute.amazonaws.com/~ec2-user/Hermes/getAlarmInfo.php/")!
        let postString = "coordinateA=" + coordinateA + "&coordinateB=" + coordinateB + "&deviceID=374a9s9dfs&alarmNum=alarm2"
        print("@@@@@@@@@@@@@@\(postString)@@@@@@@@@@@@@@")
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
                var traffic = String(json["traffic"]["trafficAmount"].stringValue)
                var weather = String(json["weather"]["weatherType"].stringValue)
                
                print("weather: \(weather)")
                print("traffic: \(traffic)")
                /*
                 DispatchQueue.main.async{
                 //self.destination.text = "Traffice Delay: \(self.delay)"
                 }
                 */
                var delay = 0
                switch traffic {
                case "Heavy"  :
                    print("Heavy")
                    delay += Heavy
                    break
                    
                case "Mild" :
                    print("Mild")
                    delay += Mild
                    break
                    
                case "Medium"  :
                    print("Medium")
                    delay += Mild
                    break
                    
                case "Low" :
                    print("Low")
                    delay += Low
                    break
                default :
                    print("else")
                    break
                }
                switch weather {
                case "rain"  :
                    print("Rain")
                    delay += Rain
                    break
                    
                case "snow" :
                    print("Snow")
                    delay += Snow
                    break
                    
                case "sleet"  :
                    print("Sleet")
                    delay += Sleet
                    break
                    
                case "wind" :
                    print("Wind")
                    delay += Wind
                    break
                default :
                    print("else")
                    break
                }
                
                var maxDelay = max(Rain, Snow, Sleet, Wind) + max(Heavy, Mild, Low)
                
                
                
                
                self.difference = maxDelay - delay
                
                let storageController = UIAlertController(title: "Alarm", message: "Traffic:\(traffic) and Weather:\(weather). Woken up \(delay) minutes early", preferredStyle: .alert)
                print("difference: \(self.difference)")
                let currentDate = Date()
                if (currentDate > (origDate.addingTimeInterval(TimeInterval(-delay)))){
                    self.difference = 0;
                }
            }
            
        }.resume()
        sleep(2)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(difference*60), execute: {
           
       
        
            self.playSound(soundName)
        //schedule notification for snooze
        if isSnooze {
            let snoozeOption = UIAlertAction(title: "Snooze", style: .default) {
                (action:UIAlertAction)->Void in self.audioPlayer?.stop()
                self.alarmScheduler.setNotificationForSnooze(snoozeMinute: 10, soundName: soundName, index: index)
            }
            storageController.addAction(snoozeOption)
        }
        let stopOption = UIAlertAction(title: "OK", style: .default) {
            (action:UIAlertAction)->Void in self.audioPlayer?.stop()
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
            self.alarmModel = Alarms()
            self.alarmModel.alarms[index].onSnooze = false
            //change UI
            var mainVC = self.window?.visibleViewController as? MainAlarmViewController
            if mainVC == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mainVC = storyboard.instantiateViewController(withIdentifier: "Alarm") as? MainAlarmViewController
            }
            mainVC!.changeSwitchButtonState(index: index)
        }
        
        storageController.addAction(stopOption)
            self.window?.visibleViewController?.navigationController?.present(storageController, animated: true, completion: nil)
             })
    }
    
    //snooze notification handler when app in background
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        var index: Int = -1
        var soundName: String = ""
        if let userInfo = notification.userInfo {
            soundName = userInfo["soundName"] as! String
            index = userInfo["index"] as! Int
        }
        self.alarmModel = Alarms()
        self.alarmModel.alarms[index].onSnooze = false
        if identifier == Id.snoozeIdentifier {
            alarmScheduler.setNotificationForSnooze(snoozeMinute: 9, soundName: soundName, index: index)
            self.alarmModel.alarms[index].onSnooze = true
        }
        completionHandler()
    }
    
    //print out all registed NSNotification for debug
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        print(notificationSettings.types.rawValue)
    }
    
    //AlarmApplicationDelegate protocol
    func playSound(_ soundName: String) {
        
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
            nil,
            { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            },
            nil)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        }
        
        //negative number to loop infinity
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.play()
    }
    
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
   
    //UIApplicationDelegate protocol
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//        audioPlayer?.pause()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        audioPlayer?.play()
        alarmScheduler.checkNotification()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    



}

