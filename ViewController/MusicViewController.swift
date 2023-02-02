//
//  MusicViewController.swift
//  Music
//
//  Created by Hira on 2019/10/18.
//  Copyright © 2019 王一平. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicViewController: UIViewController {

    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var songNum: Int!
    var newMode: [String]!
    var model = SongModel()
    var artist: String!
    let MusicView = MusicListViewController()

    @IBOutlet var mView: MusicView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mView.backSong.addTarget(self, action: #selector(backMusic), for: .touchUpInside)
        mView.nextSong.addTarget(self, action: #selector(nextMusic), for: .touchUpInside)
        mView.play.addTarget(self, action: #selector(playing), for: .touchUpInside)
        mView.slider.addTarget(self, action: #selector(sliderValue), for: .valueChanged)
        mView.modeBtn.addTarget(self, action: #selector(chooseMode), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        let aaa = UserDefaults.standard.integer(forKey: "songNumber")
        //使用者切歌的if判斷，如果是同首歌將不做任何事
        if songNum != aaa {
            songNum = UserDefaults.standard.integer(forKey: "songNumber")
            newMode = UserDefaults.standard.stringArray(forKey: "songFile") ?? []
            playTheSong()
            player?.play()
            mView.play.setImage(UIImage(named: "Pause"), for: .normal)
            modeSet()
        }
        //告诉系统接受远程監聽事件，并注册成为第一响应者
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        //耳機插拔監聽事件
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        //電話中斷事件
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterrupted), name: AVAudioSession.interruptionNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        //停止接受远程响应事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }

    //MARK: 是否能成為第一響應對象
    override var canBecomeFirstResponder: Bool {
        return true
    }

    //MARK: 鎖屏界面的按钮控制方法
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            print("no event")
            return
        }

        if event.type == UIEvent.EventType.remoteControl {
            switch event.subtype {
            case .remoteControlTogglePlayPause:
                print("暫停/播放")
            case .remoteControlPreviousTrack:
                print("上一首")
                backMusic()
            case .remoteControlNextTrack:
                print("下一首")
                nextMusic()
            case .remoteControlPlay:
                print("播放")
                player?.play()
                mView.play.setImage(UIImage(named: "Pause"), for: .normal)
            case .remoteControlPause:
                print("暫停")
                player?.pause()
                mView.play.setImage(UIImage(named: "Play"), for: .normal)
                //設置後台播放顯示信息,0為停止
                setInfoCenterCredentials(playbackState: 0)
            default:
                break
            }
        }
    }
    //MARK: - UI控制

    //MARK: 下一首
    @objc func nextMusic() {
        if songNum == (model.song.count - 1) {
            songNum = 0
        } else {
            if let _ = songNum {
                songNum += 1
            } else {
                songNum = 0
            }
        }
        let num = songNum
        artist = newMode[num!]
        artist.removeFirst(17)
        playTheSong()
        playing()
        UserDefaults.standard.set(songNum, forKey: "songNumber")
        UserDefaults.standard.set(newMode, forKey: "songFile")
    }

    //MARK: 上一首
    @objc func backMusic() {

        if songNum == 0 {
            songNum = (model.song.count - 1)
        } else {
            if let _ = songNum {
                songNum -= 1
            } else {
                songNum = 0
            }
        }
        let num = songNum
        artist = newMode[num!]
        artist.removeFirst(17)
        playTheSong()
        playing()
        UserDefaults.standard.set(songNum, forKey: "songNumber")
        UserDefaults.standard.set(newMode, forKey: "songFile")
    }

    //MARK: slider設定
    @objc func sliderValue() {
        let seconds = Int64(mView.slider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
    }

    //MARK: 模式設定
    @objc func chooseMode(_ sender: UIButton) {
        if newMode == model.song {
            mView.modeBtn.setImage(UIImage(named: "mod1"), for: .normal)
            var model2 = model.song
            model2.shuffle()
            newMode = model2
        } else {
            mView.modeBtn.setImage(UIImage(named: "mod"), for: .normal)
            newMode = model.song
        }
        UserDefaults.standard.set(songNum, forKey: "songNumber")
        UserDefaults.standard.set(newMode, forKey: "songFile")
    }

    //MARK: 播放&暫停
    @objc func playing() {
        if player?.rate == 0 {
            mView.play.setImage(UIImage(named: "Pause"), for: .normal)
            player?.play()
        } else {
            mView.play.setImage(UIImage(named: "Play"), for: .normal)
            player?.pause()
            self.setInfoCenterCredentials(playbackState: 0)
        }
    }

    //MARK: 耳機插拔監聽方法
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int,
            let reason: AVAudioSession.RouteChangeReason = AVAudioSession.RouteChangeReason(rawValue: UInt(reasonValue)) else { return }

        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                print("in")
                player?.play()
                DispatchQueue.main.async {
                    self.mView.play.setImage(UIImage(named: "Pause"), for: .normal)
                }
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    print("out")
                    player?.pause()
                    DispatchQueue.main.async {
                        self.mView.play.setImage(UIImage(named: "Play"), for: .normal)
                    }
                    break
                }
            }
        default: ()
        }
    }

    //MARK: 電話中斷監聽方法
    @objc func audioInterrupted(_ notification: Notification) {
        guard player != nil, let userInfo = notification.userInfo else { return }
        let type_tmp = userInfo[AVAudioSessionInterruptionTypeKey] as! NSNumber
        let type = AVAudioSession.InterruptionType(rawValue: type_tmp.uintValue)

        switch type! {
        case .began:
            print("中斷")
            player?.pause()
            DispatchQueue.main.async {
                self.mView.play.setImage(UIImage(named: "Play"), for: .normal)
            }
        default:
            print("中斷結束")
            let option_tmp = userInfo[AVAudioSessionInterruptionOptionKey] as! NSNumber
            let option = AVAudioSession.InterruptionOptions(rawValue: option_tmp.uintValue)
            if option == .shouldResume {
                player?.play()
                DispatchQueue.main.async {
                    self.mView.play.setImage(UIImage(named: "Pause"), for: .normal)
                }
            }
        }
    }

    //MARK: - 播放音樂
    func playTheSong() {
        if songNum == nil || newMode == [] {
            songNum = 0
            newMode = model.song
        }
        if songNum != nil {
            if let url = Bundle.main.url(forResource: newMode[songNum], withExtension: "mp3") {
                playerItem = AVPlayerItem(url: url)
                player = AVPlayer(playerItem: playerItem)
                mView.songName.text = newMode[songNum]
            } else {
                let falseAlert = UIAlertController(title: "錯誤", message: "找不到此歌曲", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                falseAlert.addAction(alertAction)
                self.present(falseAlert, animated: true, completion: nil)
            }
        }
        _ = updateUI()
        observeCurrentTime()
    }

    //MARK: 更新UI
    func updateUI() -> Float64 {
        let duration = playerItem?.asset.duration
        let seconds = CMTimeGetSeconds(duration!)
        mView.slider.minimumValue = 0
        mView.slider.maximumValue = Float(seconds)
        mView.slider.isContinuous = true
        return seconds
    }

    //MARK: 時間轉為分秒
    func formatConversion(time: Float64) -> String {
        let t = Int(time)
        var time2 = ""
        time2 = String(format: "%02d:%02d", t / 60, t % 60)
        return time2
    }

    func modeSet() {
        if newMode == model.song {
            mView.modeBtn.setImage(UIImage(named: "mod"), for: .normal)
        } else {
            mView.modeBtn.setImage(UIImage(named: "mod1"), for: .normal)
        }
    }

    //MARK: 時間與slider & 監聽事件
    func observeCurrentTime() {
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            if self.player?.currentItem?.status == .readyToPlay && self.player?.rate != 0 {
                let currentTime = CMTimeGetSeconds((self.player!.currentTime()))
                self.mView.slider.value = Float(currentTime)
                self.mView.songTime.text = self.formatConversion(time: currentTime)
                let songAllTime = self.updateUI()
                if currentTime >= songAllTime {
                    self.nextMusic()
                }
                self.setInfoCenterCredentials(playbackState: 1)
            }
        })
    }

    //MARK: 背景播放設定
    func setInfoCenterCredentials(playbackState: Int) {
        let mpic = MPNowPlayingInfoCenter.default()
        let mysize = CGSize(width: 400, height: 400)
        ///圖片封面
        let albumArt = MPMediaItemArtwork(boundsSize: mysize) { (size) -> UIImage in
            return UIImage(named: "MapleStory")!
        }

        ///獲取進度
        let postion = Double(self.mView.slider.value)
        let duration = Double(self.mView.slider.maximumValue)

        ///音樂名稱
        let artist = self.artist

        mpic.nowPlayingInfo = [MPMediaItemPropertyTitle: "[MapleStory BGM]",
                               MPMediaItemPropertyArtist: artist,
                               MPMediaItemPropertyArtwork: albumArt,
                               MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
                               MPMediaItemPropertyPlaybackDuration: duration,
                               MPNowPlayingInfoPropertyPlaybackRate: playbackState
        ]
    }
}

extension MusicViewController: ChangeSong {
    func changeSong(songFile: [String], songAlbum: String, songNumber: Int) {
        songNum = UserDefaults.standard.integer(forKey: "songNumber")
        newMode = UserDefaults.standard.stringArray(forKey: "songFile") ?? []
    }
}
