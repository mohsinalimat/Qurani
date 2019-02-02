//
//  SQAyahPlayerViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/21/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import DOFavoriteButton
import YYText
//import LNPopupController

class SQAyahPlayerViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var textView: YYTextView!
    @IBOutlet weak var progressView: SQLinearProgressView!
    @IBOutlet weak var leftDurationLabel: UILabel!
    @IBOutlet weak var rightDurationLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var completeButton: DOFavoriteButton!

    
    @IBOutlet weak var mainControlsStack: UIStackView!
    @IBOutlet weak var extraControlsStack: UIStackView!
    
    //MARK: Outlets -> Buttons
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    var tooltip: SexyTooltip?
    
    //MARK: Variables
        
    var ayat: [SQAyah]! = []
    
    var favoriteRange: SQFavoriteRange!
    
    var soundManager: SQSoundManager {
        return SQSoundManager.default
    }
    
    var lastSelectedItem: SQSoundItem?
    var lastClearedItemsQueue: [SQSoundItem?]?
    
    var timer: Timer?
    var font: UIFont! {
        didSet {
            textView.font = font
        }
    }
    
    //MARK: Super Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textView.textAlignment = .center
        textView.textVerticalAlignment = .center
        textView.isUserInteractionEnabled = false
        textView.textColor = Colors.title
        
        titleLabel.textColor = Colors.title
        detailsLabel.textColor = Colors.lightGray
        
        completeButton.circleColor = Colors.yetAnotherTint
        completeButton.lineColor = Colors.tint
        completeButton.imageColorOn = Colors.tint
        completeButton.imageColorOff = Colors.lightGray
        
        for button in mainControlsStack.arrangedSubviews {
            button.tintColor = Colors.title
        }
        
        progressView.barColor = Colors.tint
        progressView.trackColor = Colors.semiWhite
        
        leftDurationLabel.textColor = Colors.lightGray
        rightDurationLabel.textColor = Colors.lightGray
        
        rateButton.tintColor = Colors.tint
        restartButton.tintColor = Colors.tint
        
        configureTimer()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SQAyahPlayerViewController.didChangeCurrentItem(_:)), name: NSNotification.Name(rawValue: NSNotification.Name.currentSoundItemChange), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SQAyahPlayerViewController.updatePlayingStatus), name: NSNotification.Name(rawValue: NSNotification.Name.soundItemPlayingStatusChange), object: nil)
        
        
        updateAllViews(lastSelectedItem)
        updateProgress()

        font = UIFont(name: "me_quran", size: SQSettingsController.fontSize())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tooltip?.dismiss(animated: true)
    }
    
    deinit {
        self.timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: Functions
extension SQAyahPlayerViewController {
    
    /* recieved when changing the current sound item, mmmm just update the views. */
    func didChangeCurrentItem(_ notification: Notification){
        let soundItem = notification.userInfo?[Keys.soundItem] as? SQSoundItem
        updateAllViews(soundItem)
    }

    //MARK: Updating..
    func updatePlayingStatus(){
        /* update the play button .. */
        self.playButton.setImage(UIImage(named: soundManager.paused ? Icons.play.fileName : Icons.pause.fileName), for: .normal)
    }
    
    func updateProgress(){
        let progress = CGFloat(soundManager.currentTime / soundManager.duration) * 100
        self.progressView.progressValue = progress
        
        
        let remainingTime = soundManager.duration - soundManager.currentTime;
        self.leftDurationLabel.text = self._convertTime(soundManager.currentTime)
        self.rightDurationLabel.text = String(format: "-%@", _convertTime(remainingTime))
        
        self.popupItem.progress = Float(soundManager.currentTime / soundManager.duration)
    }
    
    func updatePopupBar(soundItem: SQSoundItem?){
        guard let item = soundItem else {
            return
        }
        let ayah = item.ayah
        
        
        /* updating the popup item with latest informations.. */
        let title = Names.Surah.one + " " + ayah.surah.name + " - " + "ال" + Names.Ayah.one + " " + ayah.index.localized
        let subtitle = Labels.popupSubtitle
        self.popupItem.progress = Float(soundManager.currentTime / soundManager.duration)
        self.popupItem.title = title
        self.popupItem.subtitle = subtitle
    }
    
    
    func updateAllViews(_ soundItem: SQSoundItem?){
        self.lastSelectedItem = soundItem
        
        /* this will reset the sound queue to the zero..*/
        guard let item = soundItem else {
            return
        }
        
        self.repeatButton.tintColor = self.soundManager.autorepeat == true ? Colors.tint : Colors.lightGray
        rateButton.setImage(_imageForRateValue(soundManager.rateValue), for: UIControlState())
        
        completeButton.isSelected = favoriteRange.ayahIsCompleted(item.ayah)
        
        self.textView.text = item.ayah.text
        self.titleLabel.text = "ال\(Names.Ayah.one) \(item.ayah.index.localized)"
        self.detailsLabel.text = "\(Names.Surah.one) \(item.ayah.surah.name!)"
        
        /* enabling or disabling the main media controls.. */
        self.previousButton.isEnabled = soundManager.hasPrevious
        
        
        updateProgress()
        updatePlayingStatus()
    }
    
    fileprivate func _convertTime(_ timeInterval: TimeInterval) -> String {
        let timeInt = Int(round(timeInterval))
        let (hh, mm, ss) = (timeInt / 3600, (timeInt % 3600) / 60, (timeInt % 3600) % 60)
        
        let hhString: String? = hh > 0 ? hh.localized : nil
        let mmString = (hh > 0 && mm < 10 ? 0.localized : "") + mm.localized
        let ssString = (ss < 10 ? 0.localized : "") + ss.localized
        
        return (hhString != nil ? (hhString! + ":") : "") + mmString + ":" + ssString
    }
    
    fileprivate func _imageForRateValue(_ value: Float) -> UIImage? {
        switch value {
        case SQSoundManager.RateType.x1.rawValue:
            return Icons.rate1.image
        case SQSoundManager.RateType.x2.rawValue:
            return Icons.rate2.image
        case SQSoundManager.RateType.x3.rawValue:
            return Icons.rate3.image
        default:
            return nil
        }
    }
    
    
    func configureTimer() {
        self.timer = Timer.every(0.1.seconds) { [weak self] in
            guard let me = self else { return }
            me.updateProgress()
        }
    }
}

//MARK: Actions
extension SQAyahPlayerViewController {
    @IBAction func toggleComplete(_ sender: DOFavoriteButton) {
        if let ayah = self.lastSelectedItem?.ayah {
            completeButton.isSelected ? favoriteRange.uncomplete(ayah: ayah) : favoriteRange.complete(ayah: ayah)
        }
        
        self.completeButton.isSelected ? completeButton.deselect() : completeButton.select()
    }
    
    
    @IBAction func toggleRate(){
        soundManager.nextRate()
        self.rateButton.setImage(_imageForRateValue(soundManager.rateValue), for: UIControlState())
    }
    
    func tapAnimation(toView: UIView){
        let animation = CABasicAnimation(keyPath: "transform")
        let transform = CATransform3DIdentity
        let scaled = CATransform3DScale(transform, 0.85, 0.85, 1.0)
        
        animation.duration = 0.2
        animation.isRemovedOnCompletion = true
        animation.autoreverses = true
        animation.toValue = scaled
        
        toView.layer.add(animation, forKey: "scale")
    }
    
    
    @IBAction func playOrPause(){
        /* provide a custom animation for the play button.. */
        tapAnimation(toView: playButton)
        soundManager.paused ? soundManager.resume() : soundManager.pause()
    }
    
    @IBAction func playNext(){
        tapAnimation(toView: nextButton)
        self.soundManager.next()
    }
    
    @IBAction func playPrevious(){
        tapAnimation(toView: previousButton)
        self.soundManager.previous()
    }

    
    @IBAction func toggleRepeatState(){
        soundManager.autorepeat = !soundManager.autorepeat
        self.repeatButton.tintColor = self.soundManager.autorepeat == true ? Colors.tint : Colors.lightGray
    }
    
    @IBAction func restart(){
        self.soundManager.restart()
    }
    
    @IBAction func buttonLongPress(sender: UILongPressGestureRecognizer){
        if sender.state != .ended { return }
        if let view = sender.view {
            presentTooltip(for: view)
        }
    }
    
    func presentTooltip(for view: UIView){
        var message: String! = ""
        
        switch view.tag {
        case 1:
            message = Labels.Tips.repeat
            break
        case 2:
            message = Labels.Tips.restart
            break
        case 3:
            message = Labels.Tips.rate
            break
        default:
            return
        }
        
        if self.tooltip?.isShowing == true {
            tooltip?.dismiss(animated: true)
        }
        
        tooltip = SexyTooltip(attributedString: NSAttributedString(string: message, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]))
        tooltip?.hasShadow = true
        tooltip?.dismiss(inTimeInterval: 5, animated: true)
        tooltip?.contentView.backgroundColor = Colors.tint
        tooltip?.color = Colors.tint
        self.view.addSubview(tooltip!)
        
        let halfHeight = view.height / 2
        let newCenter = CGPoint(x: view.center.x, y: view.center.y - halfHeight)
        let convertedPoint = self.view.convert(newCenter, from: extraControlsStack)
        tooltip?.present(from: convertedPoint, in: self.view)
    }
}


