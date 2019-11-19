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
    
    func moveUp(view: UIView){
        view.center.y -= 331
    }
    
    func moveDown(view: UIView){
        view.center.y += 331
    }
    
    func moveRight(label: UILabel, label2: UILabel){
        label.center.x += 30
        label2.center.x += 30
    }
    
    func moveLeft(label: UILabel, label2: UILabel){
        label.center.x -= 30
        label2.center.x -= 30
    }
    
    func animateIn(){
        UIView.animate(withDuration: 0.4) {
            albumImageViewIsHidden?.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.moveUp(view: equalizerViewIsHidden!)
                self.moveRight(label: nowPlayingTitle!, label2: nowPlayingSinger!)
                albumImageSmallView!.isHidden = false
            }) { (true) in
                lyricViewIsHidden?.isHidden = false
            }
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration: 0.4) {
            lyricViewIsHidden?.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.moveDown(view: equalizerViewIsHidden!)
                self.moveLeft(label: nowPlayingTitle!, label2: nowPlayingSinger!)
                albumImageSmallView!.isHidden = true
            }) { (true) in
                albumImageViewIsHidden?.isHidden = false
            }
        }
    }
    
    @IBAction func btnPlay(_ sender: Any) {
//        if mediaPlayer.playbackState == .playing{
//            btnPlay.setImage(#imageLiteral(resourceName: "Play Button (Big)"), for: .normal)
//            mediaPlayer.pause()
//        }else{
//            btnPlay.setImage(#imageLiteral(resourceName: "Mini Pause Button-1"), for: .normal)
//            mediaPlayer.play()
//        }
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            if audioPlayer?.isPlaying == true{
                btnPlay.setImage(#imageLiteral(resourceName: "Play Button (Big)"), for: .normal)
                audioPlayer?.pause()
            }else{
                btnPlay.setImage(#imageLiteral(resourceName: "Mini Pause Button-1"), for: .normal)
                audioPlayer?.play()
                audioPlayer?.volume = 1.0
            }
        }else{
            do {
                let audioPath = Bundle.main.path(forResource: dummyProduct[0].songTitle , ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
                audioPlayer?.play()
                nowPlayingTitle?.text = dummyProduct[0].songTitle
                nowPlayingSongTitle = nowPlayingTitle!.text!
                nowPlayingAlbum!.image = dummyProduct[thisSong].albumImage
                nowPlayingSongSinger = dummyProduct[thisSong].songSinger
                nowPlayingAlbumImage = dummyProduct[thisSong].albumImage
                UserDefaults.standard.set("true", forKey: "isPlaying")
                btnPlay.setImage(#imageLiteral(resourceName: "Pause Button (Big)"), for: .normal)
                btnNext.isEnabled = true
                btnPrevious.isEnabled = true
            } catch {
                print("Can't set the next song")
            }
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
            if audioPlayer?.isPlaying == false{
                nowPlayingSongTitle = dummyProduct[thisSong].songTitle
                nowPlayingSongSinger = dummyProduct[thisSong].songSinger
                nowPlayingAlbumImage = dummyProduct[thisSong].albumImage
                nowPlayingTitle?.text = nowPlayingSongTitle
                nowPlayingSinger?.text = nowPlayingSongSinger
                nowPlayingAlbum?.image = nowPlayingAlbumImage
                albumImageSmallView?.image = nowPlayingAlbumImage
            }else{
                audioPlayer?.play()
                nowPlayingSongTitle = dummyProduct[thisSong].songTitle
                nowPlayingSongSinger = dummyProduct[thisSong].songSinger
                nowPlayingAlbumImage = dummyProduct[thisSong].albumImage
                nowPlayingTitle?.text = nowPlayingSongTitle
                nowPlayingSinger?.text = nowPlayingSongSinger
                nowPlayingAlbum?.image = nowPlayingAlbumImage
                albumImageSmallView?.image = nowPlayingAlbumImage
            }
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
            if audioPlayer?.isPlaying == false{
                nowPlayingSongTitle = dummyProduct[thisSong].songTitle
                nowPlayingSongSinger = dummyProduct[thisSong].songSinger
                nowPlayingAlbumImage = dummyProduct[thisSong].albumImage
                nowPlayingTitle?.text = nowPlayingSongTitle
                nowPlayingSinger?.text = nowPlayingSongSinger
                nowPlayingAlbum?.image = nowPlayingAlbumImage
                albumImageSmallView?.image = nowPlayingAlbumImage
            }else{
                audioPlayer?.play()
                nowPlayingSongTitle = dummyProduct[thisSong].songTitle
                nowPlayingSongSinger = dummyProduct[thisSong].songSinger
                nowPlayingAlbumImage = dummyProduct[thisSong].albumImage
                nowPlayingTitle?.text = nowPlayingSongTitle
                nowPlayingSinger?.text = nowPlayingSongSinger
                nowPlayingAlbum?.image = nowPlayingAlbumImage
                albumImageSmallView?.image = nowPlayingAlbumImage
            }
            
        } catch {
            print("Can't set the next song")
        }
    }
    
    
    @IBAction func btnRepeat(_ sender: Any) {
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
        audioPlayer?.volume = 1.0
    }
    
    
    @IBAction func btnShuffle(_ sender: Any) {
        let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
        audioPath?.shuffled()
    }
    
    @IBAction func btnVibrate(_ sender: Any) {
        if btnVibrateOutlet.currentImage == #imageLiteral(resourceName: "Vibrate Button On"){
            btnVibrateOutlet.setImage(#imageLiteral(resourceName: "Vibrate Button Off"), for: .normal)
        }else{
            btnVibrateOutlet.setImage(#imageLiteral(resourceName: "Vibrate Button On"), for: .normal)
        }
    }

    @IBAction func btnLirik(_ sender: Any) {
        if lirik{
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button On"), for: .normal)
            animateIn()
            print("animate on")
            lirik = false
        }else{
            btnLirikOutlet.setImage(#imageLiteral(resourceName: "Lyric Button Off"), for: .normal)
            animateOut()
            print("animate off")
            lirik = true
        }
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        audioPlayer?.currentTime   = Float64(timeSlider.value)
    }
    @IBAction func sliderVolume(_ sender: UISlider) {
        if audioStuffed == true
        {
            audioPlayer?.volume = sender.value
        }
    }
}
   
