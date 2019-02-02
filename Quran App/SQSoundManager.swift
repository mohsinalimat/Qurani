//
//  SQSoundManager.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/23/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import AVFoundation
import Whisper
import MediaPlayer


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension SettingsKeys {
    static let lastRateValue = "Last Rate Value"
}

extension Keys {
    static let soundItem = "soundItem"
}

extension NSNotification.Name {
    static let currentSoundItemChange = "DidChangeCurrentSoundItem"
    static let soundItemPlayingStatusChange = "SoundItemPlayingStatus"
}


class SQSoundManager: NSObject, AVAudioPlayerDelegate {
    
    enum RateType: Float {
        case x1 = 1.0, x2 = 1.25, x3 = 1.5

    }
    
    static var `default`: SQSoundManager = SQSoundManager(soundsItems: nil)
    
    //MARK: Properties
    
    var rateType: RateType! {
        didSet {
            _audioPlayer?.rate = rateValue
            
            UserDefaults.standard.set(rateType.rawValue, forKey: SettingsKeys.lastRateValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var rateValue: Float {
        return rateType.rawValue
    }
    
    // Called each time a sound item finishs playing..
    var itemCompletion: ((_ didFinish: Bool) -> Void)?
    
    
    fileprivate(set) var paused: Bool = true {
        didSet {
            /* autosetted by the manager, only setted when transitioning between playing and paused states.. ( setting a new queue while playing won't change the state.. ) */
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.soundItemPlayingStatusChange), object: self, userInfo: nil)
            
            /* diable/enable display dimming .. */
            UIApplication.shared.isIdleTimerDisabled = !paused
        }
    }
    
    var hasAQueue: Bool {
        return self.itemsQueue != nil
    }
    
    var autorepeat: Bool = false
    
    var itemsQueue: [SQSoundItem]? = [] {
        didSet {
            // reset everything..
            self._currentIndex = 0
            self.currentItem = nil
            self.autorepeat = false
            
            self._audioPlayer?.stop()
            self._audioPlayer = nil
            
            queueIdentifier = nil
        }
    }
    
    /* used through the app..*/
    var queueIdentifier: String?
    
    /* used for updating the control center */
    var queueDetails: String = ""
    
    /// nil means that the player has finished playing or it did not start..
    fileprivate(set) var currentItem: SQSoundItem? = nil {
        didSet {
            if currentItem != nil {
                NotificationCenter.default.post(name: Notification.Name(rawValue: NSNotification.Name.currentSoundItemChange), object: self, userInfo: [Keys.soundItem: currentItem!])
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: NSNotification.Name.currentSoundItemChange), object: self, userInfo: nil)
            }
        }
    }
    
    var hasPrevious: Bool {
        return self._currentIndex > 1 && itemsQueue != nil
    }
    
    var hasNext: Bool {
        return (self._currentIndex < itemsQueue?.count)
    }
    
    var currentTime: TimeInterval {
        return self._audioPlayer?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        return self._audioPlayer?.duration ?? 0
    }
    
    //MARK: Private variables
    
    fileprivate let commandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    fileprivate let nowPlayingInfoCenter: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    fileprivate var nowPlayingInfo: [String : AnyObject]?

    
    fileprivate var _lastClearedItemsQueue: [SQSoundItem?]? = nil
    fileprivate var _audioPlayer: AVAudioPlayer?
    fileprivate var _currentIndex: Int = 0
    fileprivate var _didStartPlaying = false
    fileprivate var _didSayRestart = false
    
    
    init(soundsItems: [SQSoundItem]?){
        super.init()
        
        self.itemsQueue = soundsItems
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            _showErrorMessage(ErrorMessages.audioOpen)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        rateType = RateType(rawValue: UserDefaults.standard.float(forKey: SettingsKeys.lastRateValue))
        rateType = rateType == nil ? RateType(rawValue: 1) : rateType
        configureCommandCenter()
    }
    
    
    //MARK: Controlling the sound..
    
    func play(){
        /* resume if we can .. */
        if self._audioPlayer?.isPlaying == false {
            resume()
            return
        }
        _playNext()
    }
    
    func pause(){
        self._audioPlayer?.pause()
        
        /* the state has been changed.. notify the observers.. */
        self.paused = true

    }
    
    func resume(){
        self._audioPlayer?.play()
        self.paused = false
    }
    
    func next(){
        _playNext()
    }
    
    func previous(){
        if !hasPrevious {
            return
        }
        
        _currentIndex -= 2
        _playNext()
    }
    
    func restart(){
        _currentIndex -= 1
        _playNext(true)
    }
    
    
    func setQueue(_ queue: [SQSoundItem], startIndex: Int){
        if startIndex < 0 || startIndex > queue.count - 1 {
            return
        }
        
        self.itemsQueue = queue
        self._currentIndex = startIndex
    }
    
    func setCurrentItemIndex(_ next: Int){
        if itemsQueue == nil { return }
        if next < 0 || next > itemsQueue!.count - 1 {
            return
        }
        
        // reset everything..
        self._currentIndex = next
        self.currentItem = nil
        
        self._audioPlayer?.stop()
        self._audioPlayer = nil
    }
    
    func nextRate(){
        if self.rateType == .x3 {
            rateType = .x1
        } else {
            rateType = RateType(rawValue: rateType!.rawValue + 0.25)
        }
    }
    
    //MARK: Private

    
    fileprivate func _playNext(_ skipAutoRepeatCheck: Bool = false) {
        
        if autorepeat && _didStartPlaying && !skipAutoRepeatCheck {
            restart()
            _didSayRestart = false
            return
        }
        
        //capture the variables _current index, as we're going to change it later..
        let currentIndex = _currentIndex
        
        // destroy player object
        self._audioPlayer?.stop()
        self._audioPlayer = nil;
        
        // get the next object
        
        if !self.hasNext {
            self._doAfterFinishPlayingQueue()
            return
        }
        
        // ++
        _currentIndex += 1
        
        guard let item = self.itemsQueue?[currentIndex] else { return }
        
        // create new player object
        do {
            self._audioPlayer = try AVAudioPlayer(contentsOf: item.url)
        } catch {
            _lastClearedItemsQueue = self.itemsQueue
            _showErrorMessage(ErrorMessages.audioOpen)
            self.itemsQueue = nil
            return
        }
        
        self._audioPlayer?.delegate = self
        self._audioPlayer?.enableRate  = true
        self._audioPlayer?.rate = rateValue
        self._audioPlayer?.prepareToPlay()
        
        
        _audioPlayer?.play()
        self.currentItem = item
        
        _didStartPlaying = true
        
        self.updateCommandCenter()

        if self.paused == true {
            self.paused = false
        }
    }
    
    fileprivate func _showErrorMessage(_ message: String){
        let murmur = Murmur.init(title: message, backgroundColor: UIColor.alizarin, titleColor: UIColor.white, font: UIFont.systemFont(ofSize: 12), action: nil)
        show(whistle: murmur, action: .show(2))
    }
    

    fileprivate func _doAfterFinishPlayingQueue(){
        // copy the current items queue..
        if SQSettingsController.shouldRepeatQueueOnFinish() {
            let newQueue = self.itemsQueue
            let newIdentifier = self.queueIdentifier
            
            self.itemsQueue = nil
            self.itemsQueue = newQueue
            self.queueIdentifier = newIdentifier
            
            _playNext()
        } else {
            itemsQueue = nil
            paused = true
        }
    }
    
    //MARK: - Command Center
    
    func updateCommandCenter() {
        guard let items = self.itemsQueue, let currentItem = self.currentItem else { return }
        
        self.commandCenter.previousTrackCommand.isEnabled = currentItem != items.first!
        self.commandCenter.nextTrackCommand.isEnabled = currentItem != items.last!
    }
    
    func configureCommandCenter() {
        self.commandCenter.playCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            print("PLAY")
            guard let sself = self else { return .commandFailed }
            sself.play()
            return .success
        })
        
        self.commandCenter.pauseCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            print("PAUSE")
            guard let sself = self else { return .commandFailed }
            sself.pause()
            return .success
        })
        
        self.commandCenter.nextTrackCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            print("NEXT")
            guard let me = self else { return .commandFailed }
            me.next()
            return .success
        })
        
        self.commandCenter.previousTrackCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
            print("PREVIOUS")
            guard let me = self else { return .commandFailed }
            me.previous()
            return .success
        })
        
        // disabled unused command
        if #available(iOS 9.1, *) {
            [commandCenter.seekForwardCommand, commandCenter.seekBackwardCommand, commandCenter.skipForwardCommand,
             commandCenter.skipBackwardCommand, commandCenter.ratingCommand, commandCenter.changePlaybackRateCommand,
             commandCenter.likeCommand, commandCenter.dislikeCommand, commandCenter.bookmarkCommand, commandCenter.changePlaybackPositionCommand].forEach { $0.isEnabled = false }
        } else {
            // Fallback on earlier versions
        }
    }
}

//MARK: AudioPlayer and Session Delegate
extension SQSoundManager {
    func remoteControlReceivedWithEvent(_ event: UIEvent?){
        guard let event = event else { return }
        
        if !hasAQueue || _audioPlayer == nil {
            return
        }
        
        if event.type == .remoteControl {
            switch event.subtype {
            case .remoteControlStop:
                self.pause()
                break
            case .remoteControlTogglePlayPause:
                self.paused ? resume() : pause()
                break
            case .remoteControlPreviousTrack:
                if self.hasPrevious {
                    previous()
                }

                break
            case .remoteControlPause:
                self.pause()
                break
            case .remoteControlPlay:
                self.resume()
                break
            case .remoteControlNextTrack:
                if self.hasNext {
                    next()
                }
                
                break
            default:
                break
            }
        }
    }

    func beginInterruption() {
        self.paused = true
    }
    
    func endInterruption(withFlags flags: Int) {
        if AVAudioSessionInterruptionOptions(rawValue: UInt(flags)) == .shouldResume {
            self.resume()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        itemCompletion?(flag)        
        self._playNext()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        _showErrorMessage(ErrorMessages.audioOpen)
    }
}
