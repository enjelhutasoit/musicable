//
//  PlayButtonView.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 30/12/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
import Accelerate

class PlayButtonView: UIView {

    var delegate: DurationTimer?
    var songDuration: Int = 0
    var (minute, second) = (0,0)
    var referenceAlbumView: AlbumView?
    
    @IBOutlet var playBtn: UIButton!
    
    @IBAction func playButton(_ sender: UIButton) {
//        if mediaPlayer.playbackState == .playing{
//            playBtn.setImage(#imageLiteral(resourceName: "Play Button Wide"), for: .normal)
//            AudioUtilities.pauseAudio()
////            timer?.invalidate()
//        }else{
//            playBtn.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
////            if currentTime == Int(duration!){
////                referenceAlbumView?.timeProgress.setProgressWithAnimation(duration: duration!, value: 1)
////            }
////            mediaPlayer.play()
//            AudioUtilities.pauseAudio()
//            startTime()
//        }
        
        if playBtn.image(for: .normal) == #imageLiteral(resourceName: "Pause Button Wide"){
            AudioUtilities.pauseAudio()
            playBtn.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
            print("======================================================================================")
            referenceAlbumView?.timeProgress.pauseProgressAnimation(layer: layer)
            timer?.invalidate()
        }
        if playBtn.image(for: .normal) == #imageLiteral(resourceName: "Play Button Wide"){
            AudioUtilities.pauseAudio()
            playBtn.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
            print("======================================================================================")
            startTime()
        }

      
    }
    
    func startTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime),
        userInfo: nil, repeats: true)
    }
    
    @objc func updateTime(){
        second += 1
        if second == 60{
            minute += 1
            second = 0
        }
           
        let secondString = second > 9 ? "\(second)" : "0\(second)"
        let minuteString = minute > 9 ? "\(minute)" : "0\(minute)"
        referenceAlbumView?.currentTime.text = "\(minuteString):\(secondString)"
    }
}
