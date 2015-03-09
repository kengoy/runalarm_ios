//
//  MediaPlayer.swift
//  Runalarm
//
//  Created by Kengo Yoshii on 2015/03/06.
//  Copyright (c) 2015年 Kengo Yoshii. All rights reserved.
//

import AVFoundation

class MediaPlayer {
    var player : AVAudioPlayer! = nil
    var audioPath : NSURL! = nil

    init(file:String, type:String) {
        audioPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(file, ofType: type)!)
    }
    
    func play() {
        player = AVAudioPlayer(contentsOfURL: audioPath, error: nil)
        player.prepareToPlay()
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func setNumberOfLoop(numberOfLoops:Int) {
        player?.numberOfLoops = numberOfLoops
    }
}
