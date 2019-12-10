//
//  PlayView.swift
//  VTune
//
//  Created by Stefani Kurnia Permata Dewi on 07/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class PlayView: UIView {

    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeDuration: UILabel!
    @IBOutlet var currentTime: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnVibrateOutlet: UIButton!
    @IBOutlet weak var btnLirikOutlet: UIButton!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    var lirik = true
    var delegate: GetLyricDelegate?
    var vc: MusicPlayerViewController?
    
    @IBAction func btnPlay(_ sender: UIButton) {
        if mediaPlayer.playbackState == .playing{
            btnPlay.setImage(#imageLiteral(resourceName: "Play Button (Big)"), for: .normal)
            mediaPlayer.pause()
        }else{
            btnPlay.setImage(#imageLiteral(resourceName: "Pause Button (Big)"), for: .normal)
            mediaPlayer.play()
        }
    }

    @IBAction func btnNext(_ sender: Any) {
        mediaPlayer.skipToNextItem()
        
    }

    @IBAction func btnPrevious(_ sender: Any) {
        mediaPlayer.skipToPreviousItem()
    }
    
    
    @IBAction func btnRepeat(_ sender: Any) {
        
    }
    
    
    @IBAction func btnShuffle(_ sender: Any) {
        
    }
    
    @IBAction func btnVibrate(_ sender: Any) {
        if btnVibrateOutlet.currentImage == #imageLiteral(resourceName: "Vibrate Button On"){
            btnVibrateOutlet.setImage(#imageLiteral(resourceName: "Vibrate Button Off"), for: .normal)
        }else{
            btnVibrateOutlet.setImage(#imageLiteral(resourceName: "Vibrate Button On"), for: .normal)
        }
    }

    @IBAction func btnLirik(_ sender: UIButton) {
        if btnLirikOutlet.currentImage == #imageLiteral(resourceName: "Lyric Button On"){
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button Off"), for: .normal)
        }else{
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button On"), for: .normal)
            delegate?.getLyric(button: sender)
        }
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        mediaPlayer.currentPlaybackTime = TimeInterval(timeSlider.value)
    }
    
    @IBAction func sliderVolume(_ sender: UISlider) {
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float){
        let volumeView = MPVolumeView()
        let volumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
    volumeSlider?.value = volume;
        }
    }
}
