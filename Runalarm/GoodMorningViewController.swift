//
//  GoodMorningViewController.swift
//  Runalarm
//
//  Created by Kengo Yoshii on 2015/02/20.
//  Copyright (c) 2015年 Kengo Yoshii. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GoodMorningViewController: UIViewController, GADBannerViewDelegate{

    let player = MediaPlayer(file:"good_morning", type: "mp3")
    let ud = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bgImage = UIImage(named: "GoodMorningBackground.JPG")
        let bgImageRect = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height)
        let bgImageView = UIImageView(frame: bgImageRect)
        bgImageView.contentMode = UIViewContentMode.ScaleToFill
        bgImageView.image = bgImage
        self.view.addSubview(bgImageView)

        let runLabel = UILabel()
        runLabel.text = "GOOD MORNING!"
        runLabel.textColor = UIColor.whiteColor()
        runLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 36)
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

        player.play()

        var userDefault:NSUserDefaults = NSUserDefaults()
        let isAlarmSet = userDefault.boolForKey(KEY_IS_ALARM_SET)
        if isAlarmSet == true {
            let alarmHour = userDefault.integerForKey(KEY_ALARM_HOUR)
            let alarmMinute = userDefault.integerForKey(KEY_ALARM_MINUTE)
            var alarmManager : AlarmManager = AlarmManager.sharedInstance
            alarmManager.setAlarm(alarmHour, alarmMinute: alarmMinute)
        }
        
        // place add
        var wakeupCount:Int = userDefault.integerForKey(KEY_WAKEUP_COUNT)
        if wakeupCount >= 1 {
            let bannerView:GADBannerView = getAdBannerView()
            self.view.addSubview(bannerView)
        }

        userDefault.setInteger(wakeupCount+1, forKey: KEY_WAKEUP_COUNT)
    }

    override func viewDidAppear(animated: Bool) {
        var userDefault:NSUserDefaults = NSUserDefaults()
        var wakeupCount:Int = userDefault.integerForKey(KEY_WAKEUP_COUNT)

        if wakeupCount >= 3 {
            if !ud.boolForKey("reviewed") {
                let alertController = UIAlertController(
                    title: "Have a wonderful day!",
                    message: "Thank you for using this app. Could you review this app?",
                    preferredStyle: .Alert)
            
                let reviewAction = UIAlertAction(title: "Review now", style: .Default) {
                    action in
                    let url = NSURL(string: "itms-apps://itunes.apple.com/app/id974966247")
                    UIApplication.sharedApplication().openURL(url!)
                    self.ud.setObject(true, forKey: "reviewed")
                }
                let yetAction = UIAlertAction(title: "not now", style: .Default) {
                    action in
                    self.ud.setObject(false, forKey: "reviewed")
                }
                let neverAction = UIAlertAction(title: "NEVER", style: .Cancel) {
                    action in
                    self.ud.setObject(true, forKey: "reviewed")
                }
            
                alertController.addAction(reviewAction)
                alertController.addAction(yetAction)
                alertController.addAction(neverAction)
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
