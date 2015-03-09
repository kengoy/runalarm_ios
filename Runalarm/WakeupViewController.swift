//
//  WakeupViewController.swift
//  Runalarm
//
//  Created by Kengo Yoshii on 2015/02/12.
//  Copyright (c) 2015年 Kengo Yoshii. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import GoogleMobileAds


class WakeupViewController: UIViewController, GADBannerViewDelegate {

    var nowYouAreLabel:UILabel = UILabel()
    var yourActivityLabel:UILabel = UILabel()
    
    let motionActivityManager = CMMotionActivityManager()

    let motionManager = CMMotionManager()
    var x:Double = 0
    var y:Double = 0
    var z:Double = 0
    
    var motionHistoryX = Array<Double>()
    var motionHistoryY = Array<Double>()
    var motionHistoryZ = Array<Double>()
    var motionCount:Int = 0
    var motionHistoryNum:Int = 20

    var isToBeDismissed = false
    var remainingTime:Int = 3
    let motionUpdateInterval:Double = 0.1
    let motionRunningThresholdOverCount:Int = 6
    let motionErrorRate:Double = 0.001
    
    let player = MediaPlayer(file:"wakeup_03", type: "mp3")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // snooze in 5 mins
        var alarmManager : AlarmManager = AlarmManager.sharedInstance
        alarmManager.setAlarm(5)

        let bgImage = UIImage(named: "SettingBackground.JPG")
        let bgImageRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        let bgImageView = UIImageView(frame: bgImageRect)
        bgImageView.contentMode = UIViewContentMode.ScaleToFill
        bgImageView.image = bgImage
        self.view.addSubview(bgImageView)
        
        let wakeupLabel = UILabel()
        wakeupLabel.text = "WAKE UP!"
        wakeupLabel.textColor = UIColor.whiteColor()
        wakeupLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
        wakeupLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view?.addSubview(wakeupLabel)
        
        let constraintTop = NSLayoutConstraint(
            item: wakeupLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 100)
        self.view.addConstraint(constraintTop)
        
        let constraintCenter = NSLayoutConstraint(
            item: wakeupLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenter)

        let runLabel = UILabel()
        runLabel.text = "RUN TO STOP THE ALARM!"
        runLabel.textColor = UIColor.whiteColor()
        runLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 24)
        runLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view?.addSubview(runLabel)
        
        let constraintCenterXForRunLabel = NSLayoutConstraint(
            item: runLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenterXForRunLabel)
        let constraintCenterYForRunLabel = NSLayoutConstraint(
            item: runLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenterYForRunLabel)
        
        nowYouAreLabel.text = "NOW YOU ARE STILL SLEEPING."
        nowYouAreLabel.textColor = UIColor.whiteColor()
        nowYouAreLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 20)
        nowYouAreLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view?.addSubview(nowYouAreLabel)
        
        let constraintBottomForNowYouAreLabel = NSLayoutConstraint(
            item: nowYouAreLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -100)
        self.view.addConstraint(constraintBottomForNowYouAreLabel)
        
        let constraintCenterForNowYouAreLabel = NSLayoutConstraint(
            item: nowYouAreLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenterForNowYouAreLabel)
        
        yourActivityLabel.text = ""
        yourActivityLabel.textColor = UIColor.whiteColor()
        yourActivityLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 20)
        yourActivityLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view?.addSubview(yourActivityLabel)
        
        let constraintBottomForYourActivityLabel = NSLayoutConstraint(
            item: yourActivityLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -60)
        self.view.addConstraint(constraintBottomForYourActivityLabel)
        
        let constraintCenterForYourActivityLabel = NSLayoutConstraint(
            item: yourActivityLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal,
            toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.view.addConstraint(constraintCenterForYourActivityLabel)

        if (CMMotionActivityManager.isActivityAvailable()) {
            println("Creating new NSOperationQueue for startActivityUpdatesToQueue")
            motionActivityManager.startActivityUpdatesToQueue(NSOperationQueue()) { (activity: CMMotionActivity!) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateActivityData(activity)
                })
            }
        } else { // for before iphone 5s such as 5c, 5, 4s
            println("Creating new NSOperationQueue for startAccelerometerUpdatesToQueue")
            self.motionManager.accelerometerUpdateInterval = motionUpdateInterval
            self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
                (data, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateAccelerationData(data.acceleration)
                }
            }
        }

        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        player.setNumberOfLoop(-1)
        player.play()
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//        self.view.makeToast(message: "RUN! RUN! RUN!")
        
        // place add
        var userDefault:NSUserDefaults = NSUserDefaults()
        var wakeupCount:Int = userDefault.integerForKey(KEY_WAKEUP_COUNT)
        if wakeupCount >= 2 {
            let bannerView:GADBannerView = getAdBannerView()
            self.view.addSubview(bannerView)
        }
    }

    override func viewDidAppear(animated: Bool) {
        if isToBeDismissed == true {
            isToBeDismissed = false
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent) {
        if event.type == UIEventType.Motion && event.subtype == UIEventSubtype.MotionShake {
            // シェイク動作始まり時の処理
//            self.view.makeToast(message: "Shaken started.")
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if event.type == UIEventType.Motion && event.subtype == UIEventSubtype.MotionShake {
            // シェイク動作終了時の処理
//            self.view.makeToast(message: "Shaken finished.")
        }
    }
   
    func updateActivityData(data: CMMotionActivity) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        yourActivityLabel.text = ""
        if data.walking {
            nowYouAreLabel.text = "NOW YOU ARE WALKING."
        } else if data.running {
            remainingTime -= 1
            if remainingTime <= 0 {
                self.motionActivityManager.stopActivityUpdates()
                transitToGoodMorningScene()
            }
            nowYouAreLabel.text = "NOW YOU ARE RUNING."
            yourActivityLabel.text = "\(Double(remainingTime)) more seconds."
        } else if data.automotive {
            nowYouAreLabel.text = "NOW YOU ARE DRIVING."
        } else if data.stationary {
            nowYouAreLabel.text = "NOW YOU ARE NOT MOVING."
        } else if data.unknown {
            nowYouAreLabel.text = "NOW YOU ARE IN UNKNOWN ACTIVITY."
        }
    }

    func updateAccelerationData(data: CMAcceleration) {
        self.x = 0.9 * self.x + 0.1 * data.x
        self.y = 0.9 * self.y + 0.1 * data.y
        self.z = 0.9 * self.z + 0.1 * data.z
        motionHistoryX.append(self.x)
        motionHistoryY.append(self.y)
        motionHistoryZ.append(self.z)
        motionCount++

        yourActivityLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 16)

        if motionCount == motionHistoryNum {
            if isUserRunning() == true {
                remainingTime -= 1
                if remainingTime <= 0 {
                    self.motionManager.stopAccelerometerUpdates()
                    transitToGoodMorningScene()
                }
                
                nowYouAreLabel.text = "NOW YOU ARE RUNING."
                yourActivityLabel.text = "\(Double(remainingTime)) more seconds."
            } else {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                //for debug
                //yourActivityLabel.text = "\(Double(remainingTime)) more seconds." + "Count X:\(Int(isMotionXRunningConfidenceCount)) Y:\(Int(isMotionYRunningConfidenceCount)) Z:\(Int(isMotionZRunningConfidenceCount))"
            }
            motionCount = 0
            motionHistoryX.removeAll(keepCapacity: false)
            motionHistoryY.removeAll(keepCapacity: false)
            motionHistoryZ.removeAll(keepCapacity: false)
        }
    }
    
    private func isUserRunning() -> Bool {
        var vx:Double = 0
        var vy:Double = 0
        for i in 0...motionCount-1 {
            vx += motionHistoryX[i]
            vy += motionHistoryY[i]
        }
        
        var isMotionXRunningConfidenceCount:Int = 0
        var isMotionYRunningConfidenceCount:Int = 0
        var isMotionZRunningConfidenceCount:Int = 0
        var isAscentX:Bool = true;
        var isAscentY:Bool = true;
        var isAscentZ:Bool = true;
        for i in 1...motionCount-1 {
            if motionHistoryX[i-1] < motionHistoryX[i] {
                if isAscentX == false && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionXRunningConfidenceCount++
                    isAscentX = true
                }
            } else {
                if isAscentX == true && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionXRunningConfidenceCount++
                    isAscentX = false
                }
            }
            
            if motionHistoryY[i-1] < motionHistoryY[i] {
                if isAscentY == false && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionYRunningConfidenceCount++
                    isAscentY = true
                }
            } else {
                if isAscentY == true && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionYRunningConfidenceCount++
                    isAscentY = false
                }
            }
            
            if motionHistoryZ[i-1] < motionHistoryZ[i] {
                if isAscentZ == false && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionZRunningConfidenceCount++
                    isAscentZ = true
                }
            } else {
                if isAscentZ == true && abs(motionHistoryX[i-1] - motionHistoryX[i]) > motionErrorRate {
                    isMotionZRunningConfidenceCount++
                    isAscentZ = false
                }
            }
        }
        
        if isMotionXRunningConfidenceCount >= motionRunningThresholdOverCount
            && isMotionYRunningConfidenceCount >= motionRunningThresholdOverCount
            && isMotionZRunningConfidenceCount >= motionRunningThresholdOverCount {
            return true;
        } else {
            return false;
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func transitToGoodMorningScene() {
        player.stop()
        isToBeDismissed = true
        let goodMorningViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("GoodMorningScene") as UIViewController

        goodMorningViewController.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        presentViewController(goodMorningViewController, animated: true, completion: nil);
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
