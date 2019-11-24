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
import MediaPlayer

var mediaPlayer = MPMusicPlayerController.systemMusicPlayer

var thisSong = 0
var audioStuffed = false
var dummyProduct: [Song] = []

var nowPlayingSongTitle: String = ""
var nowPlayingSongSinger: String = ""
var nowPlayingAlbumImage: UIImage?
var nowPlayingTotalDuration: Int = 0
var nowPlayingCurrentTime: Int = 0

var lyricViewIsHidden: UIVisualEffectView?
var albumImageViewIsHidden: UIView?
var equalizerViewIsHidden: UIView?
var albumImageSmall: UIImage?
var albumImageSmallView: UIImageView?
var nowPlayingTitle: UILabel?
var nowPlayingSinger: UILabel?
var nowPlayingAlbum: UIImageView?
