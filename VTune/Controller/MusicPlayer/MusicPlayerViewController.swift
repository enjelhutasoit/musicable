//
//  MusicPlayerViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 04/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var albumImageView: UIView!
    @IBOutlet weak var equalizerView: UIView!
    @IBOutlet weak var playView: UIView!
    //    var trackId: Int = 0
//    var library = MusicLibrary().library
    
    var updater: CADisplayLink! = nil
    
    var referenceHeaderView: MusicPlayerHeader?
    var referenceAlbumImageView: MusicPlayerAlbumImage?
    var referenceEqualizerView: EqualizerView?
    var referencePlayView: PlayView?
    
    var songTitle: String = ""
    var songSinger: String = ""
    var albumImage: UIImage?
    var totalDuration: Int = 0
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        getData()
        updateTotalDuration()
        defaultSong()
        MPVolumeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setUpdater()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        updater.invalidate()
    }
    
    func defaultSong() {
        if musicIsPlaying == true {
            do {
                let audioPath = Bundle.main.path(forResource: dummyProduct[thisSong].songTitle , ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            } catch {
                print("Eror!")
            }
        }
    }
    
    func setUpdater() {
        updater = CADisplayLink(target: self, selector: #selector(updatingProgressItems))
        updater.preferredFramesPerSecond = 2
        updater.add(to: .current, forMode: .default)
    }
    
    @objc func updatingProgressItems() {

        audioPlayer?.delegate = self
                
        referencePlayView?.timeSlider.setValue(Float(audioPlayer!.currentTime), animated: true)
        referencePlayView?.timeSlider.maximumValue = Float(audioPlayer!.duration)
        
        
        // making normal time format of song
        let currentTimePlaying = Int(audioPlayer!.currentTime)
        let minutesPlaying = currentTimePlaying / 60
        let secondsPlaying = currentTimePlaying - minutesPlaying * 60
        referencePlayView?.currentTime.text = NSString(format: "%02d:%02d", minutesPlaying, secondsPlaying) as String
        
        let currentTimeDuration = Int(audioPlayer!.duration)
        let minutesDuration = currentTimeDuration / 60
        let secondsDuration = currentTimeDuration - minutesDuration * 60
        referencePlayView?.timeDuration.text = NSString(format: "%02d:%02d", minutesDuration, secondsDuration) as String
        
//        if audioPlayer.isPlaying {
//            playButton.setImage(#imageLiteral(resourceName: "pause-btn"), for: .normal)
//        } else {
//            playButton.setImage(#imageLiteral(resourceName: "play-btn"), for: .normal)
//        }
    }
    
    func setView(){
        if let referenceHeaderView = Bundle.main.loadNibNamed("MusicPlayerHeader", owner: self, options: nil)?.first as? MusicPlayerHeader{
            headerView.addSubview(referenceHeaderView)
            referenceHeaderView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceHeaderView = referenceHeaderView
        }
        
        if let referenceAlbumImageView = Bundle.main.loadNibNamed("MusicPlayerAlbumImage", owner: self, options: nil)?.first as? MusicPlayerAlbumImage{
            albumImageView.addSubview(referenceAlbumImageView)
            referenceAlbumImageView.frame = CGRect(x: 0, y: 0, width: albumImageView.frame.width, height: albumImageView.frame.height)
            self.referenceAlbumImageView = referenceAlbumImageView
        }
        
        if let referenceEqualizerView = Bundle.main.loadNibNamed("EqualizerView", owner: self, options: nil)?.first as? EqualizerView{
            equalizerView.addSubview(referenceEqualizerView)
            referenceEqualizerView.frame = CGRect(x: 0, y: 0, width: equalizerView.frame.width, height: equalizerView.frame.height)
            self.referenceEqualizerView = referenceEqualizerView
        }

        if let referencePlayView = Bundle.main.loadNibNamed("PlayView", owner: self, options: nil)?.first as? PlayView{
            playView.addSubview(referencePlayView)
            referencePlayView.frame = CGRect(x: 0, y: 0, width: playView.frame.width, height: playView.frame.height)
            self.referencePlayView = referencePlayView
        }
        
    }
    
    func getData(){
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            songTitle = nowPlayingSongTitle
            songSinger = nowPlayingSongSinger
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = songSinger
            referenceAlbumImageView?.nowPlayingAlbumImage.image = albumImage
            referencePlayView?.btnPrevious.isEnabled = true
            referencePlayView?.btnNext.isEnabled = true
            referencePlayView?.btnPlay.setImage(#imageLiteral(resourceName: "Pause Button (Big)"), for: .normal)
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatingProgressItems), userInfo: nil, repeats: true)
        }else{
            songTitle = "Tidak Sedang Memutar"
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = ""
            referencePlayView?.btnPrevious.isEnabled = false
            referencePlayView?.btnNext.isEnabled = false
            referenceAlbumImageView?.nowPlayingAlbumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
        }
        
    }
    
    func updateTotalDuration(){
        let minutes = totalDuration/60
        let seconds = totalDuration - minutes * 60
        referencePlayView?.timeDuration.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
}

extension MusicPlayerViewController: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
//            doNextSong()
//            musicIsPlaying = true
            audioPlayer?.play()
        }
    }
}
