//
//  NewMusicPlayerViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 23/12/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import MediaPlayer

class NewMusicPlayerViewController: UIViewController {

    @IBOutlet var songTitle: UILabel!
    @IBOutlet var songSinger: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var albumView: UIView!
    @IBOutlet var waveformView: UIView!
    @IBOutlet var playButtonView: UIView!
    @IBOutlet var footerView: UIView!
    
    var referenceHeaderView: HeaderView?
    var referenceAlbumView: AlbumView?
    var referenceWaveformView: WaveformView?
    var referencePlayButtonView: PlayButtonView?
    var referenceFooterView: FooterView?
    
    var songDuration: Int = 0
    var currentTime: Int = 0
    var timer: Timer?
    var duration: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        UserDefaults.standard.set("false", forKey: "isPlaying")
        getData()
        referenceAlbumView?.timeProgress.trackColor = #colorLiteral(red: 0.6783789396, green: 0.6743485928, blue: 0.6814785004, alpha: 1)
        // Do any additional setup after loading the view.
    }
   
    
    func setView(){
//        if let referenceHeaderView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView{
//            headerView.addSubview(referenceHeaderView)
//            referenceHeaderView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
//            self.referenceHeaderView = referenceHeaderView
//        }
        
        if let referenceAlbumView = Bundle.main.loadNibNamed("AlbumView", owner: self, options: nil)?.first as? AlbumView{
            albumView.addSubview(referenceAlbumView)
            referenceAlbumView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceAlbumView = referenceAlbumView
            referenceAlbumView.albumImage.layer.cornerRadius = referenceAlbumView.albumImage.frame.height/2
        }
        
        if let referenceWaveformView = Bundle.main.loadNibNamed("WaveformView", owner: self, options: nil)?.first as? WaveformView{
            waveformView.addSubview(referenceWaveformView)
            referenceWaveformView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceWaveformView = referenceWaveformView
        }
        
        if let referencePlayButtonView = Bundle.main.loadNibNamed("PlayButtonView", owner: self, options: nil)?.first as? PlayButtonView{
            playButtonView.addSubview(referencePlayButtonView)
            referencePlayButtonView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referencePlayButtonView = referencePlayButtonView
        }
        
        if let referenceFooterView = Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)?.first as? FooterView{
            footerView.addSubview(referenceFooterView)
            referenceFooterView.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
            self.referenceFooterView = referenceFooterView
        }
    }
    
    func getData(){
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            if let nowPlaying = MPMusicPlayerApplicationController.applicationQueuePlayer.nowPlayingItem{
                referenceAlbumView?.albumImage.image = nowPlaying.artwork?.image(at: CGSize(width: (referenceAlbumView?.albumImage.frame.height)!, height: (referenceAlbumView?.albumImage.frame.width)!))
                songTitle.text = nowPlaying.title
                songSinger.text = nowPlaying.artist
                referencePlayButtonView?.playButton.setImage(#imageLiteral(resourceName: "Pause Button Wide"), for: .normal)
            }
            
        }else{
            referenceAlbumView?.albumImage.image = #imageLiteral(resourceName: "tidak sedang memutar image")
            songTitle.text = "Tidak sedang memutar lagu"
            songSinger.text = " "
            referenceAlbumView?.currentTime.text = "00:00"
        }
    }
    
    func getSongDuration(){
        if let nowPlaying = MPMusicPlayerApplicationController.applicationQueuePlayer.nowPlayingItem{
                songDuration = Int(nowPlaying.playbackDuration)
                currentTime = Int(mediaPlayer.currentPlaybackTime)
                duration = nowPlaying.playbackDuration
                referenceAlbumView?.timeProgress.setProgressWithAnimation(duration: duration!, value: 1)
                referenceAlbumView?.timeProgress.progressColor = #colorLiteral(red: 0, green: 0.8623425364, blue: 0.690444231, alpha: 1)
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime),
                userInfo: nil, repeats: true)
    //            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(songDurationProgress),
    //            userInfo: nil, repeats: true)
                
        }
        print(songDuration)
    }
    
    @objc func updateTime(){
        currentTime = Int(mediaPlayer.currentPlaybackTime)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        referenceAlbumView?.currentTime.text = String(String(format: "%02d:%02d", minutes,seconds) as String)
    }
        
    func songDurationProgress(){
        referenceAlbumView?.timeProgress.trackColor = #colorLiteral(red: 0.6783789396, green: 0.6743485928, blue: 0.6814785004, alpha: 0.8032962329)
        referenceAlbumView?.timeProgress.progressColor = #colorLiteral(red: 0, green: 0.8623425364, blue: 0.690444231, alpha: 1)
    //        timeProgress.setProgressWithAnimation(duration: duration!, value: Float(currentTime/songDuration))
    }
    
    @IBAction func addSongAction(_ sender: UIButton) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
    
}

extension NewMusicPlayerViewController: MPMediaPickerControllerDelegate{
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaPlayer.play()
        mediaPicker.dismiss(animated: true) {
            self.getSongDuration()
            self.getData()
        }
        print("lagu diplay")
        
        print("get data berhasil")
        print("get duration berhasil")
        mediaPicker.showsItemsWithProtectedAssets = false
        UserDefaults.standard.set("true", forKey: "isPlaying")
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
