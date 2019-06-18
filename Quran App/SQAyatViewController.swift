//
//  SQAyat1ViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import pop
import Whisper
import DOFavoriteButton

fileprivate let kCellIdentifierKey = "AyaRepCell"

class SQAyatViewController: UIViewController {
    
    
    //MARK: Variables
    fileprivate var _alreadyTap: Bool = false
    
    var shouldUseSurahInfoAsHeroIDs = false {
        didSet {
            updateViews()
        }
    }
    
    var surahInfo: SQSurahInfo!  {
        return favoriteRange!.surahInfo!
    }
    
    var currentAyahIndex: Int = -1
    
    var playerViewController: SQAyahPlayerViewController!
    var miniPlayerViewController: SQMiniPlayerViewController!

    var soundManager: SQSoundManager {
        return SQSoundManager.default
    }
 
    var ayat: [SQAyah]! {
        return favoriteRange.ayat
    }
    
    lazy var font: UIFont = {
        return UIFont(name: "KFGQPC HAFS Uthmanic Script", size: SQSettingsController.fontSize())!
    }()
    
    var favoriteRange: SQFavoriteRange! {
        didSet {
            SQQuranStateManager.shared.currentFavoriteRange = favoriteRange
            updateViews()
        }
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var playButton: SQPlayButton!
    @IBOutlet weak var checkmarkButton: DOFavoriteButton!
    
    //MARK: Super Methods and Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playButton.hero.id = "button"
        
        
        if favoriteRange == nil {
            fatalError("INITIALIZING AYAT VIEW CONTROLLER WITHOUT SPECIFIYING A FAVORRITE RANGE!!")
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100        
        
        titleLabel.textColor = Colors.title
        detailsLabel.textColor = Colors.lightGray
        playButton.backgroundColor = Colors.tint
        backButton.tintColor = Colors.tint
        tableView.separatorColor = Colors.semiWhite
        
        navigationController?.hero.navigationAnimationType = .slide(direction: .right)
        
        
        playerViewController = SQAyahPlayerViewController.create(from: "Player", withIdentifier: "Player")
        playerViewController.favoriteRange = favoriteRange

        miniPlayerViewController = SQMiniPlayerViewController.create(from: "Player", withIdentifier: "MiniPlayer")
        popupBar.customBarViewController = miniPlayerViewController
        
        updateViews()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            headerView.bounds = CGRect(x: 0, y: 0, width: tableView.width, height: 180)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        NotificationCenter.default.addObserver(self, selector: #selector(SQAyatViewController.didChangeCurrentSoundItem(_:)), name: NSNotification.Name(rawValue: NSNotification.Name.currentSoundItemChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SQAyatViewController.updateButtonStatus), name: NSNotification.Name(rawValue: NSNotification.Name.soundItemPlayingStatusChange), object: nil)
        
        if soundManager.currentItem == nil {
            currentAyahIndex = -1
        }
        
        // repacing font
//        font = UIFont(name: "me_quran", size: SQSettingsController.fontSize())
        
        updateViewsWithSoundItem(soundManager.currentItem)
        playButton.setButtonState(soundManager.paused ? .paused : .playing, animated: false, shouldSendActions: false)

        
        soundManager.itemCompletion = { finished in
            if !SQSettingsController.shouldAutoComplete() { return }
            if let ayah = SQSoundManager.default.currentItem?.ayah, let favoriteRange = SQQuranStateManager.shared.currentFavoriteRange, finished && !(favoriteRange.ayahIsCompleted(ayah))  {
                favoriteRange.complete(ayah: ayah)
            }
        }
        
        favoriteRange.new = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
}

//MARK: TableView
extension SQAyatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ayat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierKey) as! SQAyaRepTableViewCell

        let ayaRep = ayat[indexPath.row]
        
        let shouldHighlight = indexPath.row == currentAyahIndex && soundManager.queueIdentifier == favoriteRange.identifier
        
        let labelColor = shouldHighlight ? Colors.tint : Colors.contents
        let backgroundColor = shouldHighlight ? Colors.tint.withAlphaComponent(0.2) : UIColor.white
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 0
//        paragraphStyle.lineHeightMultiple = 1.0
//        paragraphStyle.alignment = .right
//
//        let attributedText = NSAttributedString(string: ayaRep.text + " \(indexPath.row.localized)", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: labelColor, NSAttributedString.Key.font: font])
        
<<<<<<< HEAD
        cell.set(text: ayaRep.text + " \(indexPath.row.localized)", color: labelColor)
=======
        let attributedText = NSAttributedString(string: ayaRep.text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: labelColor, NSAttributedString.Key.font: font])
>>>>>>> 049312e98cf36689ad0b0d11a4aabb0b7b8afec1
        
//        cell.label.attributedText = attributedText
        cell.cornerLabel.text = "\(ayaRep.index!.localized)"
        cell.backgroundColor = backgroundColor
        
        cell.button.isSelected = favoriteRange.ayahIsCompleted(ayaRep)
        cell.button.circleColor = Colors.yetAnotherTint
        cell.button.lineColor = Colors.tint
        cell.button.imageColorOn = Colors.tint
        cell.button.imageColorOff = Colors.lightGray
        
        
        weak var  me = self
        cell.onButtonTap = { [unowned self] selected in
            // get ayah for the index path.
            if let ayah = me?.favoriteRange.ayat[indexPath.row] {
                selected ? me?.favoriteRange.complete(ayah: ayah) : self.favoriteRange.uncomplete(ayah: ayah)
                
                if let progress = me?.favoriteRange.progress {
                    self.checkmarkButton.isSelected = progress == 1
                }
            }
        }
        
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // specify the range..
        let ayat = self.ayat
        _alreadyTap = true
        
        /* if there is currently no queue.. */
        if soundManager.itemsQueue == nil {
            soundManager.setQueue(ayat!.map { SQSoundItem(url: $0.url!, ayah: $0) }, startIndex: indexPath.row)
            setQueueInfo()
        }
        
        
        /* we are in the same queue, so just move the HEAD.. */
        if soundManager.queueIdentifier == favoriteRange?.identifier {
            soundManager.setCurrentItemIndex(indexPath.row)
            
            /* otherwise, we are in different favorite range, so reset the queue.. */
        } else {
            soundManager.setQueue(ayat!.map { SQSoundItem(url: $0.url!, ayah: $0) }, startIndex: indexPath.row)
            setQueueInfo()
        }
        
        soundManager.play()
    }

    func setQueueInfo(){
        soundManager.queueIdentifier = favoriteRange.identifier
        soundManager.queueDetails = favoriteRange.description
    }
}

//MARK: Methods
extension SQAyatViewController {
    func updateViews(){
        if titleLabel != nil {
            titleLabel.text = favoriteRange.name
            detailsLabel.text = favoriteRange.description
            self.checkmarkButton.isSelected = favoriteRange.progress == 1
            
            self.titleLabel.hero.id = ( shouldUseSurahInfoAsHeroIDs ? favoriteRange.surahInfo.surahName! :  favoriteRange.description ) + "Title"
            self.detailsLabel.hero.id = ( shouldUseSurahInfoAsHeroIDs ? favoriteRange.surahInfo.surahName! : favoriteRange.description ) + "Details"
            self.view.hero.id = ( shouldUseSurahInfoAsHeroIDs ? favoriteRange.surahInfo.surahName : favoriteRange.description ) + "Cell"
        }
    }

    func goToAyah(_ ayah: SQAyah){
        if let indexPathRow = self.ayat.binarySearch(key: ayah){
            let ayah = ayat[indexPathRow]
            let surah = ayah.surah
            if surah != self.surahInfo.surah {
                return
            }
            
            self.tableView.scrollToRow(at: IndexPath(row: indexPathRow, section: 0), at: .middle, animated: true)
        }
    }
    
    
    func updateViewsWithSoundItem(_ soundItem: SQSoundItem?){
        self.playerViewController.lastSelectedItem = soundItem
        
        guard let item = soundItem else {
            if soundManager.itemsQueue == nil {
                
                self.currentAyahIndex = -1
                self.tableView.reloadData()
                
                if !SQSettingsController.shouldRepeatQueueOnFinish() {
                    dismissPopupBar(animated: true, completion: nil)
                }
            }
            
            return
        }
        
        self.playerViewController.updatePopupBar(soundItem: item)
        

        let previousIndex = self.currentAyahIndex
        
        /* using binary search: a much faster algorithim for sorted array.. */
        if let index = self.favoriteRange.ayat.binarySearch(key: item.ayah) {
            self.currentAyahIndex = index
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0), IndexPath(row: previousIndex, section: 0)], with: .automatic)
        }
        
        if _alreadyTap {
            _alreadyTap = false
        } else  {
            self.goToAyah(item.ayah)
        }
        
        if self.popupPresentationState == .hidden {
            showMiniPlayer()
        }
    }
    
    func showMiniPlayer(){
        if self.popupPresentationState == .hidden {
            popupBar.customBarViewController = miniPlayerViewController
            self.presentPopupBar(withContentViewController: playerViewController, animated: true, completion: nil)
        }
    }
    
    @objc func updateButtonStatus(){
        let paused = self.soundManager.paused
        let playButtonStatePaused = self.playButton.buttonState == .paused
        
        if paused != playButtonStatePaused {
            self.playButton.setButtonState(paused ? .paused : .playing, animated: true, shouldSendActions: false)
        }
    }
    
    @IBAction func back(){
        navigationController?.hero.navigationAnimationType = .slide(direction: .left)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: Actions and Methods
extension SQAyatViewController {
    @objc func didChangeCurrentSoundItem(_ notification: Notification){
        let currentItem = notification.userInfo?[Keys.soundItem] as? SQSoundItem
        self.updateViewsWithSoundItem(currentItem)
    }
    
    @IBAction func goToTop(_ sender: AnyObject) {
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: true)
    }
    
    
    @IBAction func playButtonTap(_ sender: AnyObject) {    }
    
    @IBAction func playButtonValueChange(){
        if playButton.buttonState == .paused {
            /* pause the sound queue .. */
            soundManager.pause()
        } else {
            /* resume the sound queue or re-play again .. but make sure that the current queue identifier matches the current favorite range.. */
            if soundManager.paused && soundManager.queueIdentifier == favoriteRange.identifier {
                soundManager.resume()
            } else {
                soundManager.setQueue(ayat.map { return SQSoundItem(url: $0.url!, ayah: $0) }, startIndex: 0)
                setQueueInfo()
                soundManager.play()
            }
        }
    }
    
    @IBAction func completeButtonTapped(button: DOFavoriteButton) {
        button.isSelected ? button.deselect() : button.select()
        button.isSelected ? self.favoriteRange.completeAll() : self.favoriteRange.uncompleteAll()
        self.tableView.reloadData()
    }
}


//MARK: Additions
extension SQAyatViewController {
    fileprivate func _ayahWhoseIndex(_ index: Int) -> SQAyah? {
        for ayah in ayat {
            if ayah.index == index {
                return ayah
            }
        }; return nil
    }
}



// احتفالاً بالسطر رقم ١٠٠٠ حبيت أخلي هاظ السطر للقطاعة 😜🙈😍
