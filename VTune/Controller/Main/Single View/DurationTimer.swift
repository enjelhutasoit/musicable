//
//  Timer.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 10/01/20.
//  Copyright © 2020 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation

class SongDurationTimer{
    var songDuration: Int = 0
    var (minute, second) = (0,0)
    var referenceAlbumView: AlbumView?
    
    func startTimer(){
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
