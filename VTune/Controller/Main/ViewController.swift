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

class ViewController: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var musicPlayerMiniView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var addSongButtonOutlet: UIBarButtonItem!
    
    var referenceMusicPlayerMini: MusicPlayerMini?
    var songs: [Song] = []
    var flag = false
    var likeCounter = 0
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSong: [Song] = []

    var songList: SongListTableViewCell?
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        runningText()
        UserDefaults.standard.set("false", forKey: "isPlaying")
//        getData()
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Cari Lagu"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredSong = songs.filter { (song: Song) -> Bool in
      return song.songTitle.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
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
    
    func runningText(){
        referenceMusicPlayerMini?.songTitle.tag = 601
        referenceMusicPlayerMini?.songTitle.type = .continuous
        referenceMusicPlayerMini?.songTitle.speed = .duration(15.0)
        referenceMusicPlayerMini?.songTitle.fadeLength = 10.0
        referenceMusicPlayerMini?.songTitle.trailingBuffer = 30.0
    }
    
    func playSong(songs: [Song], completion: @escaping ((Error?) -> Void)) {
        self.songs = songs
//        self.queuedSongs = songs
//        self.nowPlayingSong = nil
        var songIdentifiers = [String]()
        songs.forEach { (song) in
            songIdentifiers.append(song.id)
        }
        mediaPlayer.beginGeneratingPlaybackNotifications()
        mediaPlayer.setQueue(with: songIdentifiers)
        mediaPlayer.play()
        getData()
        completion(nil)
    }
    
    func getData(){
        if let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem{
            nowPlayingSongTitle = nowPlaying.title!
            nowPlayingSongSinger = nowPlaying.albumArtist!
            nowPlayingTotalDuration = Int(nowPlaying.playbackDuration)
            nowPlayingAlbumImage = nowPlaying.artwork?.image(at: CGSize(width: (referenceMusicPlayerMini?.photoAlbum.frame.width)!, height: (referenceMusicPlayerMini?.photoAlbum.frame.height)!))
            referenceMusicPlayerMini?.songTitle.text = nowPlayingSongTitle
            referenceMusicPlayerMini?.photoAlbum.image = nowPlayingAlbumImage
            print("Fungsi getData() Berhasil")
        }
        if UserDefaults.standard.string(forKey: "isPlaying") == "true"{
            referenceMusicPlayerMini?.songTitle.text = nowPlayingSongTitle
            referenceMusicPlayerMini?.NextButtonOutlet.isEnabled = true
            referenceMusicPlayerMini?.previewButtonOutlet.isEnabled = true
            referenceMusicPlayerMini?.photoAlbum.image = nowPlayingAlbumImage
        }else{
            referenceMusicPlayerMini?.songTitle.text = "Tidak Sedang Memutar Lagu"
            referenceMusicPlayerMini?.NextButtonOutlet.isEnabled = false
            referenceMusicPlayerMini?.previewButtonOutlet.isEnabled = false
            referenceMusicPlayerMini?.photoAlbum.image = #imageLiteral(resourceName: "tidak sedang memutar image")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    @IBAction func switchSegmentedControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        self.tableView.reloadData()
    }
    
    @IBAction func goToMusicPlayer(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "goToNextVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! MusicPlayerViewController
//        vc.songTitle = nowPlayingSongTitle
//        vc.songSinger = nowPlayingSongSinger
//        vc.albumImage = nowPlayingAlbumImage
//        vc.totalDuration = nowPlayingTotalDuration
//        if mediaPlayer.playbackState == .playing{
//            vc.referencePlayView!.btnPlay.setImage(#imageLiteral(resourceName: "Mini Pause Button-1"), for: .normal)
//        }
    }
    
     
    
    @IBAction func addLaguFromiTunes(_ sender: Any) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender as? UIView
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
}

// Table View
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if isFiltering {
                value = filteredSong.count
            } else {
                value = songs.count
            }
            break
        case 1:
            for product in songs
            {
                if product.isFavorite
                {
                    value+=1
                }
                    
                if isFiltering {
                    value = filteredSong.count
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
    
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if isFiltering {
                cell.displayData(filteredSong[indexPath.row])
            } else {
                cell.displayData(songs[indexPath.row])
                cell.songTitleLabel.text = songs[indexPath.row].songTitle
            }
            break

        case 1:
            if songs[indexPath.row].isFavorite && isFiltering
            {
                cell.displayData(filteredSong[indexPath.row])
            } else {
                cell.displayData(songs[indexPath.row])
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
            songs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if isFiltering {
                let slicedTracks = Array(self.songs[indexPath.row...(self.songs.count - 1)])
                self.playSong(songs: slicedTracks, completion: { (error) in
                      let cell = tableView.cellForRow(at: indexPath)
                      cell?.setSelected(false, animated: true)
                  })
            } else {
                let slicedTracks = Array(self.songs[indexPath.row...(self.songs.count - 1)])
                self.playSong(songs: slicedTracks, completion: { (error) in
                        let cell = tableView.cellForRow(at: indexPath)
                        cell?.setSelected(false, animated: true)
                    })
                }
        case 1:
            for product in songs
            {
                if product.isFavorite
                {
                    
                }
                    
                if isFiltering {
                   
                }
            }
        default:
            break
        }
            
        UserDefaults.standard.set("true", forKey: "isPlaying")
        getData()
    }
}

extension ViewController: FavoriteDelegate {
    func isFavorite(song: Song?) {
        guard let song = song else {return}
        if let index = songs.firstIndex(where: {$0.songTitle == song.songTitle}) {
        let isFav =  songs[index].isFavorite
        songs[index].isFavorite = !isFav
        tableView.reloadData()
        }
    }
}

extension ViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
  let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

// Music Kit

extension ViewController: MPMediaPickerControllerDelegate{
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPlayer.setQueue(with: mediaItemCollection)
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaPlayer.play()
        mediaPicker.showsItemsWithProtectedAssets = false
        referenceMusicPlayerMini?.playButtonOutlet.setImage(#imageLiteral(resourceName: "Pause Button (Small)"), for: .normal)
        UserDefaults.standard.set("true", forKey: "isPlaying")
        getData()
        
        for i in 0...(mediaItemCollection.count-1){
            let currentTime = Int(mediaItemCollection.items[i].playbackDuration)
            let minutes = currentTime/60
            let seconds = currentTime - minutes * 60
            
            songs.append(Song(songTitle: (mediaItemCollection.items[i].title)!, songSinger: (mediaItemCollection.items[i].albumArtist)!, songDuration: String(format: "%02d:%02d", minutes,seconds) as String, favIcon: "Favourite Options Button.png", isFavorite: false, id: mediaItemCollection.items[i].playbackStoreID))
        }
        tableView.reloadData()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

