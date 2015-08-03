//
//  ViewController.swift
//  Runalarm
//
//  Created by Kengo Yoshii on 2015/02/07.
//  Copyright (c) 2015年 Kengo Yoshii. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import GoogleMobileAds

internal let KEY_IS_ALARM_SET:String = "isAlarmSet"
internal let KEY_ALARM_HOUR:String = "alarmHour"
internal let KEY_ALARM_MINUTE:String = "alarmMinute"
internal let KEY_WAKEUP_COUNT:String = "wakeupCount"

extension SettingViewController : UIPickerViewDataSource {
//    func valueForRow(row: Int, forComponent component: Int) -> Int {
    func valueForRow(row: Int, forComponent component: Int) -> String {
        // the rows repeat every `pickerViewData.count` items
        return alarmTimeCompos[component][row % alarmTimeCompos[component].count]
    }
/*
    func rowForValue(value: Int, forComponent component: Int) -> Int? {
        
        if let valueIndex = find(alarmTimeCompos[component], value) {
            if component == 0 {
                return alarmTimeHourMiddle + value
            } else {
                return alarmTimeHourMiddle + value
            }
        }
        return nil
    }
*/
}

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate {

    private var alarmHour:Int = 0
    private var alarmMinute:Int = 0
    private var isAlarmSet:Bool = false
    
//    @IBOutlet weak var alarmTimePicker: UIDatePicker!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var alarmTimePickerView: UIPickerView!
//    private let alarmTimeCompos = [Array(0...23), Array(00...59)]
    private let alarmTimeCompos = [
        ["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23"],["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
    ]
    private let pickerViewRows:Int = 10_000
    private var alarmTimeHourMiddle = 0
    private var alarmTimeMinuteMiddle = 0

    let player = MediaPlayer(file:"wakeup_03", type: "mp3")

    override func viewDidLoad() {
        super.viewDidLoad()

        bgImage.setTranslatesAutoresizingMaskIntoConstraints(true)
        let bgImageRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        bgImage.frame = bgImageRect

        self.alarmTimePickerView.delegate = self
        self.alarmTimePickerView.dataSource = self
        
        alarmTimeHourMiddle = ((pickerViewRows / alarmTimeCompos[0].count) / 2) * alarmTimeCompos[0].count
        alarmTimeMinuteMiddle = ((pickerViewRows / alarmTimeCompos[1].count) / 2) * alarmTimeCompos[1].count
        
        var userDefault:NSUserDefaults = NSUserDefaults()
        alarmHour = userDefault.integerForKey(KEY_ALARM_HOUR)
        alarmMinute = userDefault.integerForKey(KEY_ALARM_MINUTE)
        isAlarmSet = userDefault.boolForKey(KEY_IS_ALARM_SET)
        
        alarmTimePickerView.selectRow(alarmHour, inComponent: 0, animated: false)
        alarmTimePickerView.selectRow(alarmMinute, inComponent: 1, animated: false)
        alarmSwitch.setOn(isAlarmSet, animated: false)
        
        // place volume var
        let volumeViewW:CGFloat = 220
        let volumeViewH:CGFloat = 20
        let volumeViewX:CGFloat = (self.view.bounds.width / 2) - (volumeViewW / 2)
        let volumeViewY:CGFloat = (self.view.bounds.height / 2) + 90
        var wrapperView = UIView(frame: CGRectMake(volumeViewX + 20, volumeViewY, volumeViewW, volumeViewH))
        wrapperView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(wrapperView)
        var volumeView = MPVolumeView(frame: wrapperView.bounds)
        let panGesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        panGesture.cancelsTouchesInView = false
        volumeView.addGestureRecognizer(panGesture)
        wrapperView.addSubview(volumeView)

        // place volume icon
        let volIconImage = UIImage(named: "VolumeControlIcon.png")
        let volIconImageRect = CGRectMake(-50, -6, 32, 32)
        let volIconImageView = UIImageView(frame: volIconImageRect)
        volIconImageView.contentMode = UIViewContentMode.ScaleToFill
        volIconImageView.image = volIconImage
        wrapperView.addSubview(volIconImageView)
        
        // place add
        var wakeupCount:Int = userDefault.integerForKey(KEY_WAKEUP_COUNT)
        if wakeupCount >= 3 {
            let bannerView:GADBannerView = getAdBannerView()
            self.view.addSubview(bannerView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        return false
    }

    func handleGesture(gesture: UIGestureRecognizer){
        if let panGesture = gesture as? UIPanGestureRecognizer{
            switch gesture.state{
            case .Began:
                player.play()
            case .Ended , .Cancelled:
                player.stop()
            default:
                break // do nothing
            }
        }
    }

    @IBAction func onAlarmSet(sender: UISwitch) {
        isAlarmSet = sender.on

        var userDefault:NSUserDefaults = NSUserDefaults()
        userDefault.setBool(isAlarmSet, forKey: KEY_IS_ALARM_SET)

        if(isAlarmSet) {
            saveAlarmTime()
            setAlarm();
            self.view.makeToast(message: "Alarm is set for " + alarmHour.description + ":" +
                (NSString(format: "%02d", alarmMinute) as String) + ". Good night.")
        } else {
            cancelAlarm();
            self.view.makeToast(message: "Alarm is unset. ")
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return alarmTimeCompos.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewRows
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return valueForRow(row, forComponent: component)
//            return "\(valueForRow(row, forComponent: component))"
        } else {
//            return NSString(format: "%02d", valueForRow(row, forComponent: component))
            return valueForRow(row, forComponent: component)
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var newRow:Int
        if component == 0 {
            newRow = alarmTimeHourMiddle + (row % alarmTimeCompos[component].count)
        } else {
            newRow = alarmTimeMinuteMiddle + (row % alarmTimeCompos[component].count)
        }
        pickerView.selectRow(newRow, inComponent: component, animated: false)

        let row1 = pickerView.selectedRowInComponent(0)
        let row2 = pickerView.selectedRowInComponent(1)
        let item1 = self.pickerView(pickerView, titleForRow:row1, forComponent:0)
        let item2 = self.pickerView(pickerView, titleForRow:row2, forComponent:1)
        alarmHour = item1.toInt()!
        alarmMinute = item2.toInt()!

        if(isAlarmSet) {
            saveAlarmTime()
            setAlarm()
            self.view.makeToast(message: "Alarm is reset for " + item1 + ":" + item2 + ". Good night.")
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let label = UILabel()
        label.text = "\(valueForRow(row, forComponent: component))"
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont (name: "HelveticaNeue-UltraLight", size: 40)
        return label
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 75
    }
    
    private func saveAlarmTime() {
        var userDefault:NSUserDefaults = NSUserDefaults()
        userDefault.setInteger(alarmHour, forKey: KEY_ALARM_HOUR)
        userDefault.setInteger(alarmMinute, forKey: KEY_ALARM_MINUTE)
    }

    private func setAlarm() {
        var alarmManager : AlarmManager = AlarmManager.sharedInstance
        alarmManager.setAlarm(alarmHour, alarmMinute: alarmMinute)
    }

    private func cancelAlarm() {
        var alarmManager : AlarmManager = AlarmManager.sharedInstance
        alarmManager.cancelAlarm()
    }
    
    private func getAdBannerView() -> GADBannerView {
        var bannerView: GADBannerView = GADBannerView()
        bannerView = GADBannerView(adSize:kGADAdSizeBanner)
        bannerView.frame.origin = CGPointMake(0, self.view.frame.size.height - bannerView.frame.height)
        bannerView.frame.size = CGSizeMake(self.view.frame.width, bannerView.frame.height)
        bannerView.adUnitID = "ca-app-pub-2622423706255892/9601933969" // Enter Ad's ID here
        bannerView.delegate = self
        bannerView.rootViewController = self
        
        var request:GADRequest = GADRequest()
//        request.testDevices = [GAD_SIMULATOR_ID]
        bannerView.loadRequest(request)
        
        return bannerView
    }

    func adViewDidReceiveAd(adView: GADBannerView){
        println("adViewDidReceiveAd:\(adView)")
    }
    func adView(adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError){
        println("error:\(error)")
    }
    func adViewWillPresentScreen(adView: GADBannerView){
        println("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(adView: GADBannerView){
        println("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(adView: GADBannerView){
        println("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(adView: GADBannerView){
        println("adViewWillLeaveApplication")
    }
}

