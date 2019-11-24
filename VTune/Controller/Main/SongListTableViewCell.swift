//
//  SongListTableViewCell.swift
//  VTune
//
//  Created by Enjelina on 07/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

class SongListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var favoriteButtonLabel: UIButton!
    
    
    var flag = false
    var likeCounter = 0
    static let shared = SongListTableViewCell()
    
    var song: Song?
//    var delegate: FavoriteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
        flag = !flag
        setButtonImage()
    }
    
    func setButtonImage(){
        if likeCounter == 0
        {
            let image1 = UIImage(named: "Like Icon.png")!
            self.favoriteButtonLabel.setImage(image1, for: .normal)
            likeCounter = 1
        }
        else
        {
            let image1 = UIImage(named: "Favourite Options Button.png")!
            self.favoriteButtonLabel.setImage(image1, for: .normal)
            likeCounter = 0
        }
//        delegate?.isFavorite(song: song)
    }
    
    func displayData(_ data: Song) {
        song = data
        songTitleLabel.text = data.songTitle
        singerLabel.text = data.songSinger
        songDurationLabel.text = data.songDuration
//        var image1: UIImage?
//        if data.isFavorite {
//            image1 = UIImage(named: "Like Icon.png")!
//        }else {
//            image1 = UIImage(named: "Favourite Options Button.png")!
//        }
//        guard let image2  =  image1 else  {return}
//        self.favoriteButtonLabel.setImage(image2, for: .normal)
    }
    
}

