//
//  PlayButtonView.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 30/12/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import Foundation

class PlayButtonView: UIView {

    var referenceAlbumView: AlbumView?
    
    @IBOutlet var playButton: UIButton!
    
    
    @IBAction func playButton(_ sender: UIButton) {
        if mediaPlayer.playbackState == .playing{
            playButton.setImage(#imageLiteral(resourceName: "Play Button Wide"), for: .normal)
//            mediaPlayer.pause()
            AudioUtilities.pauseAudio()
            timer?.invalidate()
        }else{
            playButton.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
//            if currentTime == Int(duration!){
//                referenceAlbumView?.timeProgress.setProgressWithAnimation(duration: duration!, value: 1)
//            }
//            mediaPlayer.play()
            AudioUtilities.pauseAudio()
            timer?.invalidate()
        }
    }
}
