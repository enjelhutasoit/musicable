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
//
//protocol GetDataDelegate{
//    func getData()
//}

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
    
    var lirik = true
    var delegate: GetLyricDelegate?
    var vc: MusicPlayerViewController?
    var referenceHeaderView: MusicPlayerHeader?
    var referenceAlbumImageView: MusicPlayerAlbumImage?
    var getDataDelegate: GetDataDelegate?
    
    func getData(){
        if let nowPlaying = mediaPlayer.nowPlayingItem{
        nowPlayingSongTitle = nowPlaying.title!
        nowPlayingSongSinger = nowPlaying.artist!
        nowPlayingTotalDuration = Int(nowPlaying.playbackDuration)
        referenceAlbumImageView?.nowPlayingAlbumImage.image = nowPlaying.artwork?.image(at: CGSize(width: (referenceAlbumImageView?.nowPlayingAlbumImage.frame.width)!, height: (referenceAlbumImageView?.nowPlayingAlbumImage.frame.height)!))
        referenceHeaderView?.nowPlayingSongTitle.text = nowPlayingSongTitle
        referenceHeaderView?.nowPlayingSinger.text = nowPlayingSongSinger
        referenceAlbumImageView?.nowPlayingAlbumImage.image = nowPlayingAlbumImage
        print("Fungsi getData() Berhasil")
        }
    }
    
    func updateTotalDuration(){
        let minutes = nowPlayingTotalDuration/60
        let seconds = nowPlayingTotalDuration - minutes * 60
        timeDuration.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
    
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
        mediaPlayer.stop()
        updateTotalDuration()
        getData()
        mediaPlayer.play()
    }

    @IBAction func btnPrevious(_ sender: Any) {
        mediaPlayer.skipToPreviousItem()
        mediaPlayer.stop()
        updateTotalDuration()
        getData()
        mediaPlayer.play()
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
   
