//
//  SegueInfo.swift
//  Alarm-ios-swift


import Foundation

struct SegueInfo {
    var curCellIndex: Int
    var isEditMode: Bool
    var label: String
    var mediaLabel: String
    var mediaID: String
    var repeatWeekdays: [Int]
    var enabled: Bool
    var snoozeEnabled: Bool
    
    var delay: String
    var autoTW: Bool
}
