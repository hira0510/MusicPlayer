//
//  MusicListViewController.swift
//  Music
//
//  Created by Hira on 2019/10/21.
//  Copyright © 2019 王一平. All rights reserved.
//

import UIKit

protocol ChangeSong {
    func changeSong(songFile: [String], songAlbum: String, songNumber: Int)
}

class MusicListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var model = SongModel()
    var model2: [String]?
    var songNumber2: Int?
    //var delegate : ChangeSong?
    //var secondVC = UIStoryboard(name: "MusicPlayer", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MusicListCollectionViewCell.nib, forCellWithReuseIdentifier: "MusicListCollectionViewCell")
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        //隨機播放的新排序
        model2 = UserDefaults.standard.stringArray(forKey: "songFile") ?? model.song
        songNumber2 = UserDefaults.standard.integer(forKey: "songNumber")
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.song.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicListCollectionViewCell", for: indexPath) as! MusicListCollectionViewCell
        cell.labelAndPhoto(text: model.song[indexPath.item], image: UIImage(named: model.photo)!)
        if model2 != model.song && model2![songNumber2!].contains(model.song[indexPath.item]) == true {
            cell.lableColor(bool: true)
        } else if model2 == model.song && model2![songNumber2!].contains(model.song[indexPath.item]) == true {
            cell.lableColor(bool: true)
        } else {
            cell.lableColor(bool: false)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        //這裡的意思是：如果是隨機播放(model2)的話，用for迴圈跟if判斷去找出點選的歌曲(model[點選])在隨機播放的第i個位置
        //用意是：使用者點選隨機播放後，播放的順序會改變，但播放列表的排序不會動。如果A歌原本在第2個位置，點選隨機播放後A會跑到第i個位置，此時再回來播放列表點選A歌的位置(2)，已經變B歌了；所以要讓原本播放列表的A歌去比對現在的A歌在哪裡，找到後再把新的位置(i)使用UserDefaules傳值給播放器

        if model2 != model.song {
            for i in 0...(model.song.count - 1) {
                if model2![i].contains(model.song[indexPath.item]) == true {
                    UserDefaults.standard.set(i, forKey: "songNumber")
                    UserDefaults.standard.set(model2, forKey: "songFile")
                }
            }
        } else {
            UserDefaults.standard.set(indexPath.item, forKey: "songNumber")
            UserDefaults.standard.set(model2, forKey: "songFile")
        }
        tabBarController?.selectedIndex = 1
        //delegate = secondVC
        //delegate?.changeSong(songFile: model.song, songAlbum: model.photo, songNumber: indexPath.item)
    }
}
