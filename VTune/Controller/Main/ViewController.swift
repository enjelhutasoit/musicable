//
//  MainViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 07/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UISearchBarDelegate, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var musicPlayerMiniView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addLagu: UIBarButtonItem!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    var referenceMusicPlayerMini: MusicPlayerMini?
    var dummyProduct: [DummySongList] = []
    var dummyFavorit: [DummySongFavorit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setView()
        dummyProduct = createArray()
        dummyFavorit = createArray2()
    }
    
    func setupNavBar(){
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Cari Lagu"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setView(){
        if let referenceMusicPlayerMini = Bundle.main.loadNibNamed("MusicPlayerMini", owner: self, options: nil)?.first as? MusicPlayerMini{
            musicPlayerMiniView.addSubview(referenceMusicPlayerMini)
            referenceMusicPlayerMini.frame = CGRect(x: 0, y: 0, width: musicPlayerMiniView.frame.width, height: musicPlayerMiniView.frame.height)
            self.referenceMusicPlayerMini = referenceMusicPlayerMini
        }
        
        tableView.register(UINib.init(nibName: "SongListTableViewCell", bundle: nil), forCellReuseIdentifier: "SongListTableViewCell")
        tableView.reloadData()
    }
    
    func createArray() -> [DummySongList]{
        var tempSong: [DummySongList] = []
        
        let song1 =  DummySongList(songTitle: "Playing With Fire", songSinger: "BLACKPINK")
        let song2 =  DummySongList(songTitle: "Boombayah", songSinger: "BLACKPINK")
        let song3 =  DummySongList(songTitle: "Yes or Yes", songSinger: "Twice")
        let song4 =  DummySongList(songTitle: "Love Shot", songSinger: "EXO")
        let song5 =  DummySongList(songTitle: "Love, Poem", songSinger: "IU")
        let song6 =  DummySongList(songTitle: "Bad Boy", songSinger: "Red Velvet")
        
        tempSong.append(song1)
        tempSong.append(song2)
        tempSong.append(song3)
        tempSong.append(song4)
        tempSong.append(song5)
        tempSong.append(song6)
        
        return tempSong
    }
    
    func createArray2() -> [DummySongFavorit]{
        var tempSong: [DummySongFavorit] = []
        
        let song1 =  DummySongFavorit(songTitle: "Love Shot", songSinger: "EXO")
        let song2 =  DummySongFavorit(songTitle: "BYes or Yes", songSinger: "Twice")
        let song3 =  DummySongFavorit(songTitle: "Bad Boy", songSinger: "Red Velvet")
     
        tempSong.append(song1)
        tempSong.append(song2)
        tempSong.append(song3)
        
        return tempSong
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
   
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaPlayer.play()
        mediaPicker.showsItemsWithProtectedAssets = false
        
        getData()
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchSegmentedControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            value =  dummyProduct.count
            break
        case 1:
            value = dummyFavorit.count
            break
        default:
            break
        }
        
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let song = dummyProduct[indexPath.row]
        //        let favorit = dummyFavorit[indexPath.row]
                
                let cell = Bundle.main.loadNibNamed("SongListTableViewCell", owner: self, options: nil)?.first as! SongListTableViewCell
                
                switch segmentedControl.selectedSegmentIndex {
                case 0:
                    cell.songTitleLabel.text = dummyProduct[indexPath.row].songTitle
                    cell.singerLabel.text = dummyProduct[indexPath.row].songSinger
                    break
                case 1:
                    cell.songTitleLabel.text = dummyFavorit[indexPath.row].songTitle
                    cell.singerLabel.text = dummyFavorit[indexPath.row].songSinger
                    break
                default:
                    break
                }
                return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func getData(){
        if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem{
            referenceMusicPlayerMini?.songTitle.text = nowPlaying.title
            referenceMusicPlayerMini?.photoAlbum.image = nowPlaying.artwork?.image(at: CGSize(width: (referenceMusicPlayerMini?.photoAlbum.frame.width)!, height: (referenceMusicPlayerMini?.photoAlbum.frame.height)!))
        }
    }
    
    @IBAction func addLaguFromiTunes(_ sender: Any) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender as? UIView
        
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
}
