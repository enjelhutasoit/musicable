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
        mediaPlayer.skipToPreviousItem()
    }
    
    @IBAction func playButton(_ sender: Any) {
        if mediaPlayer.playbackState == .playing{
            playButtonOutlet.setImage(#imageLiteral(resourceName: "Play Button (Small)"), for: .normal)
            mediaPlayer.pause()
        }else{
            playButtonOutlet.setImage(#imageLiteral(resourceName: "Pause Button (Small)"), for: .normal)
            mediaPlayer.play()
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        mediaPlayer.skipToNextItem()
    }
    
}
