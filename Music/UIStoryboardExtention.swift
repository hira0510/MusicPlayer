//
//  UIStoryboardExtention.swift
//  Music
//
//  Created by Hira on 2019/10/22.
//  Copyright © 2019 王一平. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func loadMusicViewController (num : Int) -> MusicViewController {
        let vc = UIStoryboard.init(name: "MusicPlayer", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        vc.songNum = num
        return vc
    }
}
