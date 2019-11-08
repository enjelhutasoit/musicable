//
//  MainViewController.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 07/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UISearchBarDelegate, MPMediaPickerControllerDelegate {

    //#EH1
    @IBOutlet weak var tableView: UITableView!
    let dummyProduct = [DummySongList]()
    
    @IBOutlet weak var addLagu: UIBarButtonItem!
    
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        // Do any additional setup after loading the view.
       
    }
    
    func setupNavBar(){
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Cari Lagu"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func setView(){
      
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
    
    @IBAction func addLaguFromiTunes(_ sender: Any) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender as? UIView
        
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
}
