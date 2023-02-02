//
//  MusicListCollectionViewCell.swift
//  Music
//
//  Created by Hira on 2019/10/21.
//  Copyright © 2019 王一平. All rights reserved.
//

import UIKit

class MusicListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var musicPhoto: UIImageView!

    static var nib: UINib {
        return UINib(nibName: "MusicListCollectionViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func labelAndPhoto(text: String, image: UIImage) {
        musicName.text = text
        musicPhoto.image = image
    }

    public func lableColor(bool: Bool) {
        if bool == true {
            musicName.textColor = UIColor(red: 30/255, green: 240/255, blue: 170/255, alpha: 1)
        } else {
            musicName.textColor = UIColor.white
        }
    }
}
