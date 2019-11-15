//
//  dummySOng.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 11/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation

class DummySongList{
    var songTitle: String?
    var songSinger: String?
    var songDuration: String?
    var favIcon:  String?
    
    init(songTitle: String, songSinger: String, songDuration: String, favIcon: String, songs: String) {
        self.songTitle = songTitle
        self.songSinger = songSinger
        self.songDuration = songDuration
        self.favIcon = favIcon
    }
}


struct Song {
    let songTitle: String
    let songSinger: String
    let songDuration: String
    let favIcon:  String
    var isFavorite: Bool
}
