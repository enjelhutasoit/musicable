//
//  MusicPlayerMini.swift
//  VTune
//
//  Created by Nova Arisma on 11/7/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class MusicPlayerMini: UIView

{
    
    @IBOutlet weak var photoAlbum: UIImageView!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var previewButtonOutlet: UIButton!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var NextButtonOutlet: UIButton!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer

    
    @IBAction func prevButton(_ sender: Any) {
//        mediaPlayer.skipToPreviousItem()
        thisSong -= 1
        
        if thisSong < 0 {
            thisSong = dummyProduct.count - 1
        }
        
        do {
            let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            songTitle.text = dummyProduct[thisSong].songTitle
            nowPlayingSongTitle = songTitle.text!
            nowPlayingSongSinger = dummyProduct[thisSong].songSinger
        } catch {
            print("Can't set the next song")
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
//        if mediaPlayer.playbackState == .playing{
//            playButtonOutlet.setImage(#imageLiteral(resourceName: "Play Button (Small)"), for: .normal)
//            mediaPlayer.pause()
//        }else{
//            playButtonOutlet.setImage(#imageLiteral(resourceName: "Pause Button (Small)"), for: .normal)
//            mediaPlayer.play()
//        }
        
        if audioPlayer.isPlaying == true{
            playButtonOutlet.setImage(#imageLiteral(resourceName: "Play Button (Small)"), for: .normal)
            audioPlayer.pause()
        }else{
            playButtonOutlet.setImage(#imageLiteral(resourceName: "Pause Button (Small)"), for: .normal)
            audioPlayer.play()
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
//        mediaPlayer.skipToNextItem()
        thisSong += 1
        
        if thisSong >= dummyProduct.count {
            thisSong = 0
        }
        
        do {
            let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            songTitle.text = dummyProduct[thisSong].songTitle
            nowPlayingSongTitle = songTitle.text!
            nowPlayingSongSinger = dummyProduct[thisSong].songSinger

        } catch {
            print("Can't set the next song")
        }
    }
    
}
