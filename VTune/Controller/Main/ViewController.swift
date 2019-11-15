//
//  MainViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 07/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

protocol FavoriteDelegate {
    func isFavorite(song: Song?)
}

class ViewController: UIViewController, UISearchBarDelegate, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var musicPlayerMiniView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var addLagu: UIBarButtonItem!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    var referenceMusicPlayerMini: MusicPlayerMini?
    var dummyProduct: [Song] = []
    var dummyFavorit: [Song] = []
    var flag = false
    var likeCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setView()
        
        dummyProduct = createArray()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func createArray() -> [Song]{
        var tempSong: [Song] = []
        let song1 =  Song(songTitle: "Potong Bebek Angsa", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        let song2 =  Song(songTitle: "Indonesia Raya", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        let song3 =  Song(songTitle: "Indonesia Pusaka", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        
        tempSong.append(song1)
        tempSong.append(song2)
        tempSong.append(song3)
        
        return tempSong
    }
    
    func createArray2() -> [Song]{
        var tempSong: [Song] = []
        
        let song1 =  Song(songTitle: "Potong Bebek Angsa", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        let song2 =  Song(songTitle: "Indonesia Raya", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        let song3 =  Song(songTitle: "Indonesia Pusaka", songSinger: "NN", songDuration: "00:00", favIcon: "Favourite Options Button.png", isFavorite: false)
        
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
            for product in dummyProduct {
                if product.isFavorite {
                    value+=1
                }
            }
            break
        default:
            break
        }
        
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SongListTableViewCell", owner: self, options: nil)?.first as! SongListTableViewCell

        cell.delegate = self
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.displayData(dummyProduct[indexPath.row])
            break
            
        case 1:
            if dummyProduct[indexPath.row].isFavorite {
            cell.displayData(dummyProduct[indexPath.row])
            }
            break
            
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            dummyProduct.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

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

extension ViewController: FavoriteDelegate {
    func isFavorite(song: Song?) {
        guard let song = song else {return}
        if let index = dummyProduct.firstIndex(where: {$0.songTitle == song.songTitle}) {
        let isFav =  dummyProduct[index].isFavorite
        dummyProduct[index].isFavorite = !isFav
        tableView.reloadData()
        }
    }
}
