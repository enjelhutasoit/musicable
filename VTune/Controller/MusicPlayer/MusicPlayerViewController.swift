//
//  MusicPlayerViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 04/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var albumImageView: UIView!
    @IBOutlet weak var equalizerView: UIView!
    @IBOutlet weak var playView: UIView!
    //    var trackId: Int = 0
//    var library = MusicLibrary().library
    
    var referenceHeaderView: MusicPlayerHeader?
    var referenceAlbumImageView: MusicPlayerAlbumImage?
    var referenceEqualizerView: EqualizerView?
    var referencePlayView: PlayView?
    
    var songTitle: String = ""
    var songSinger: String = ""
    var albumImage: UIImage?
    var totalDuration: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        getData()
        updateTotalDuration()
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
        }else{
            songTitle = "Not Playing"
            referenceHeaderView?.nowPlayingSongTitle.text = songTitle
            referenceHeaderView?.nowPlayingSinger.text = ""
            referencePlayView?.btnPrevious.isEnabled = false
            referencePlayView?.btnNext.isEnabled = false
        }
        
    }
    
    func updateTotalDuration(){
        let minutes = totalDuration/60
        let seconds = totalDuration - minutes * 60
        referencePlayView?.timeDuration.text = String(format: "%02d:%02d", minutes,seconds) as String
    }
}
