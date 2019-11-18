//
//  Manager.swift
//  VTune
//
//  Created by Jasmine Hanifa Mounir on 19/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

var audioPlayer = AVAudioPlayer()
var thisSong = 0
var audioStuffed = false
var dummyProduct: [Song] = []
var nowPlayingSongTitle: String = ""
var nowPlayingSongSinger: String = ""
var nowPlayingAlbumImage: UIImage?
var nowPlayingTotalDuration: Int = 0
var nowPlayingCurrentTime: Int = 0