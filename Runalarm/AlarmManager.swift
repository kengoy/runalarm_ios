//
//  AlarmManager.swift
//  Runalarm
//
//  Created by Kengo Yoshii on 2015/02/28.
//  Copyright (c) 2015年 Kengo Yoshii. All rights reserved.
//

import UIKit
import AVFoundation

class AlarmManager {
    private init() {
        
    }

    class var sharedInstance : AlarmManager {
        struct Static {
            static let instance : AlarmManager = AlarmManager()
        }
        return Static.instance
    }
    
    func setAlarm(alarmHour:Int, alarmMinute:Int) {
        cancelAlarm()
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound , categories: nil))

        let currentDate = NSDate()
        let calendar:NSCalendar? = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        var components:NSDateComponents = calendar!.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit,
            fromDate: currentDate)
        //NSCalendar.autoupdatingCurrentCalendar()
//        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute, fromDate: currentDate)
        
        var alarmFireDate = calendar!.dateWithEra(1, year: components.year, month: components.month, day: components.day, hour: alarmHour, minute: alarmMinute, second: 0, nanosecond: 0)
        let ret:NSComparisonResult = calendar!.compareDate(currentDate, toDate: alarmFireDate!, toUnitGranularity: .SecondCalendarUnit)
        if ret == NSComparisonResult.OrderedDescending {
            alarmFireDate = calendar!.dateByAddingUnit(.DayCalendarUnit, value: +1, toDate: alarmFireDate!, options: nil)!
        }

        var notification = UILocalNotification()
        notification.fireDate = alarmFireDate
        notification.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "Wake up"
        notification.alertAction = "OK"
        notification.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification);

        let alarmFireDateSnooze1 = calendar!.dateByAddingUnit(.SecondCalendarUnit, value: +10, toDate: alarmFireDate!, options: nil)!
        var notification1 = UILocalNotification()
        notification1.fireDate = alarmFireDateSnooze1
        notification1.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification1.timeZone = NSTimeZone.defaultTimeZone()
        notification1.alertBody = "Wake up"
        notification1.alertAction = "OK"
        notification1.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification1);

        let alarmFireDateSnooze2 = calendar!.dateByAddingUnit(.SecondCalendarUnit, value: +20, toDate: alarmFireDate!, options: nil)!
        var notification2 = UILocalNotification()
        notification2.fireDate = alarmFireDateSnooze2
        notification2.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification2.timeZone = NSTimeZone.defaultTimeZone()
        notification2.alertBody = "Wake up"
        notification2.alertAction = "OK"
        notification2.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification2);

        let alarmFireDateSnooze3 = calendar!.dateByAddingUnit(.SecondCalendarUnit, value: +30, toDate: alarmFireDate!, options: nil)!
        var notification3 = UILocalNotification()
        notification3.fireDate = alarmFireDateSnooze3
        notification3.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification3.timeZone = NSTimeZone.defaultTimeZone()
        notification3.alertBody = "Wake up"
        notification3.alertAction = "OK"
        notification3.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification3);

        let alarmFireDateSnooze4 = calendar!.dateByAddingUnit(.SecondCalendarUnit, value: +40, toDate: alarmFireDate!, options: nil)!
        var notification4 = UILocalNotification()
        notification4.fireDate = alarmFireDateSnooze4
        notification4.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification4.timeZone = NSTimeZone.defaultTimeZone()
        notification4.alertBody = "Wake up"
        notification4.alertAction = "OK"
        notification4.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification4);

        let alarmFireDateSnooze5 = calendar!.dateByAddingUnit(.SecondCalendarUnit, value: +50, toDate: alarmFireDate!, options: nil)!
        var notification5 = UILocalNotification()
        notification5.fireDate = alarmFireDateSnooze5
        notification5.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification5.timeZone = NSTimeZone.defaultTimeZone()
        notification5.alertBody = "Wake up"
        notification5.alertAction = "OK"
        notification5.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification5);

    }
    
    func setAlarm(minuteSinceNow:Int) {
        cancelAlarm()
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound , categories: nil))

        var notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60))
        notification.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "Wake up"
        notification.alertAction = "OK"
        notification.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification);

        var notification1 = UILocalNotification()
        notification1.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60 + 10))
        notification1.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification1.timeZone = NSTimeZone.defaultTimeZone()
        notification1.alertBody = "Wake up"
        notification1.alertAction = "OK"
        notification1.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification1);
        
        var notification2 = UILocalNotification()
        notification2.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60 + 20))
        notification2.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification2.timeZone = NSTimeZone.defaultTimeZone()
        notification2.alertBody = "Wake up"
        notification2.alertAction = "OK"
        notification2.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification2);
        
        var notification3 = UILocalNotification()
        notification3.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60 + 30))
        notification3.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification3.timeZone = NSTimeZone.defaultTimeZone()
        notification3.alertBody = "Wake up"
        notification3.alertAction = "OK"
        notification3.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification3);
        
        var notification4 = UILocalNotification()
        notification4.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60 + 40))
        notification4.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification4.timeZone = NSTimeZone.defaultTimeZone()
        notification4.alertBody = "Wake up"
        notification4.alertAction = "OK"
        notification4.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification4);
        
        var notification5 = UILocalNotification()
        notification5.fireDate = NSDate(timeIntervalSinceNow: (NSTimeInterval)(minuteSinceNow * 60 + 50))
        notification5.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        notification5.timeZone = NSTimeZone.defaultTimeZone()
        notification5.alertBody = "Wake up"
        notification5.alertAction = "OK"
        notification5.soundName = "wakeup_03_short.mp3"
        UIApplication.sharedApplication().scheduleLocalNotification(notification5);
    }

    func cancelAlarm() {
        UIApplication.sharedApplication().cancelAllLocalNotifications();
    }
}
