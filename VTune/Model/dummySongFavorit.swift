//
//  dummySongFavorit.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 11/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation

class DummySongFavorit{
    var songTitle: String?
    var songSinger: String?
    var songDuration: String?
    var favIcon:  String?
    
    
    
    init(songTitle: String, songSinger: String, songDuration: String, favIcon: String) {
        self.songTitle = songTitle
        self.songSinger = songSinger
        self.songDuration = songDuration
        self.favIcon = favIcon
    }
}
