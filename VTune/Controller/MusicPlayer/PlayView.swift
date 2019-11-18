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
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnVibrateOutlet: UIButton!
    @IBOutlet weak var btnLirikOutlet: UIButton!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer

    @IBAction func btnPlay(_ sender: Any) {
//        if mediaPlayer.playbackState == .playing{
//            btnPlay.setImage(#imageLiteral(resourceName: "Play Button (Big)"), for: .normal)
//            mediaPlayer.pause()
//        }else{
//            btnPlay.setImage(#imageLiteral(resourceName: "Mini Pause Button-1"), for: .normal)
//            mediaPlayer.play()
//        }
        if audioPlayer.isPlaying == true{
            btnPlay.setImage(#imageLiteral(resourceName: "Play Button (Big)"), for: .normal)
            audioPlayer.pause()
        }else{
            btnPlay.setImage(#imageLiteral(resourceName: "Mini Pause Button-1"), for: .normal)
            audioPlayer.play()
        }
    }

    @IBAction func btnNext(_ sender: Any) {
//        mediaPlayer.skipToNextItem()
        thisSong += 1
        
        if thisSong >= dummyProduct.count {
            thisSong = 0
        }
        
        do {
            let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            nowPlayingSongTitle = dummyProduct[thisSong].songTitle
            nowPlayingSongSinger = dummyProduct[thisSong].songSinger
            UserDefaults.standard.set("true", forKey: "isPlaying")
        } catch {
            print("Can't set the next song")
        }
    }

    @IBAction func btnPrevious(_ sender: Any) {
//        mediaPlayer.skipToPreviousItem()
        thisSong -= 1
        
        if thisSong < 0 {
            thisSong = dummyProduct.count - 1
        }
        
        do {
            let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            nowPlayingSongTitle = dummyProduct[thisSong].songTitle
            nowPlayingSongSinger = dummyProduct[thisSong].songSinger
        } catch {
            print("Can't set the next song")
        }
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

    @IBAction func btnLirik(_ sender: Any) {
        if btnLirikOutlet.currentImage == #imageLiteral(resourceName: "Lyric Button On"){
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button Off"), for: .normal)
        }else{
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button On"), for: .normal)
        }
    }
}
   
