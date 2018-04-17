//
//  AlarmSchedulerDelegate.swift
//  Alarm-ios-swift


import Foundation
import UIKit

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(_ date: Date, onWeekdaysForNotify weekdays:[Int], snoozeEnabled:Bool,  onSnooze: Bool, soundName: String, index: Int, maxDelay: Int, Rain: Int, Snow: Int, Sleet: Int, Wind: Int, Heavy: Int, Mild: Int, Low: Int, AutoTW: Bool, sourceLocation: String, destinationLocation: String)
    //helper
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setupNotificationSettings() -> UIUserNotificationSettings
    func reSchedule()
    func checkNotification()
}

