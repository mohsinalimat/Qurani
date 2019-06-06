//
//  SQFavoritesCollectionViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 6/29/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CFAlertViewController
import Hero

let kFavoriteCellReuseIdentifier = "Cell :D"

class SQSurahsViewController: UIViewController {

    var surahsInfos: [SQSurahInfo] = {
        return SQQuranStateManager.shared.surahInfos
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var storeButton: UIButton!
    
    var itemsCountPerRow: Int = 2
    var alertPresentation = false
    
    var pickingManager: SQPickingManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.bringSubviewToFront(plusButton)
        
        isHeroEnabled = true
        collectionView.heroModifiers = [.cascade]
        
        tabBarController?.isHeroEnabled = true
        tabBarController?.tabBar.heroModifiers = [.translate(CGPoint(x: 0, y: 64)), .useNoSnapshot, .useGlobalCoordinateSpace, .zPosition(10)]
        
        plusButton.heroID = "button"
        plusButton.tintColor = .white
        plusButton.backgroundColor = Colors.tint
        storeButton.tintColor = Colors.yetAnotherTint
        
        self.tabBarController?.tabBar.heroModifiers = [.useGlobalCoordinateSpace, .forceAnimate, .beginWith(modifiers: [.zPosition(10)])]

        titleLabel.textColor = Colors.title
        separatorView.backgroundColor = Colors.semiWhite
        
        let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(SQSurahsViewController.longPress))
        collectionView.addGestureRecognizer(gestureRec)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.storeButton.isHidden = UserDefaults.standard.bool(forKey: SettingsKeys.DidBuyPack)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if alertPresentation {
            alertPresentation = false
            return
        }
        
        toggleReloading()
    }
    
    @IBAction func newButtonTap(_ sender: AnyObject) {
        pickingManager = SQPickingManager()
        pickingManager?.delegate = self
        
        let initialVC = pickingManager?.initialViewController()
        present(initialVC!, animated: true, completion: nil)
    }
    
    func toggleReloading(){
        self.surahsInfos = SQQuranStateManager.shared.surahInfos
        
        if SQQuranStateManager.shared.hasInsertedSurahInfo {
            self.insertSurahInfo()
            self.collectionView.reloadEmptyDataSet()
            SQQuranStateManager.shared.hasInsertedSurahInfo = false
        } else if SQQuranStateManager.shared.hasDeletedSurahInfo {
            self.removeSurahInfo(at: SQQuranStateManager.shared.deletedSurahInfoIndex)
            SQQuranStateManager.shared.hasDeletedSurahInfo = false
            SQQuranStateManager.shared.deletedSurahInfoIndex = -1
        } else {
            self.reload()
        }
    }
    
}

extension SQSurahsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surahsInfos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kFavoriteCellReuseIdentifier, for: indexPath) as! SQSurahCollectionViewCell
        let surahInfo = self.surahsInfos[indexPath.row]
        
        cell.layer.borderColor = Colors.semiWhite.cgColor
        
        // cell customization here..
        cell.textLabel.text = surahInfo.surahName!
        cell.textLabel.textColor = Colors.tint
        
        cell.detailsLabel.text = Names.FavoriteRange.name(for: surahInfo.favoritedRanges.count)
        cell.detailsLabel.textColor = Colors.lightGray
        cell.topView.backgroundColor = Colors.tint
        cell.topView.isHidden = !((SQSoundManager.default.queueIdentifier?.contains(surahInfo.surahName!)) == true)
        
        /* enabling this animation will result a bad apperance during the animation.. */
//        cell.heroModifiers = ".fade, .scale(0.5)"
        cell.heroID = surahInfo.surahName! + "Cell"
        
        cell.detailsLabel.heroID = surahInfo.surahName! + "Details"
        cell.textLabel.heroID = surahInfo.surahName! + "Title"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // compute the cell size here..
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = UIScreen.main.bounds.width
        
        let itemWidth = (width - ((layout.sectionInset.right + layout.sectionInset.left) + (layout.minimumInteritemSpacing * CGFloat(itemsCountPerRow))) ) / CGFloat(itemsCountPerRow)
        return CGSize(width: itemWidth, height: itemWidth * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentNextViewController(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let surahInfo = surahsInfos[indexPath.row]
        if surahInfo.hasNewFavoritedRanges {
            cell.twinkle()
            surahInfo.hasNewFavoritedRanges = false
        }
    }
    
    func presentNextViewController(for indexPath: IndexPath){
        let surahInfo = surahsInfos[indexPath.row]
        SQQuranStateManager.shared.currentSurahInfo = surahInfo
        if surahInfo.favoritedRanges.count == 1 {
            /* directly go to the ayat view controller.. */
            
            let viewController = SQAyatViewController.create(from: "Player", withIdentifier: "Ayat")
            viewController?.favoriteRange = surahInfo.favoritedRanges.firstObject as! SQFavoriteRange
            viewController?.isHeroEnabled = true
            viewController?.shouldUseSurahInfoAsHeroIDs = true
            
            navigationController?.pushViewController(viewController!, animated: true)
            return
        }
        
        /* otherwise display the favorited ranges view controller.. */
        let viewController = SQFavoritedRangesViewController.create(from: "Player", withIdentifier: "FavoritedRanges")
        viewController?.surahInfo = surahInfo
        
        navigationController?.pushViewController(viewController!, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        itemsCountPerRow = traitCollection.horizontalSizeClass == .regular ? 3 : 2
        reload()
    }
    
    @objc dynamic func longPress(sender: UILongPressGestureRecognizer){
        if sender.state != .ended { return }
        let point = sender.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            /* Do your stuff here :D */
            askToDeleteSurahInfo(at: indexPath)
        }
    }
}

extension SQSurahsViewController {
    func askToDeleteSurahInfo(at indexPath: IndexPath){
        var didConfirm = false
        alertPresentation = true
        let surahInfo = surahsInfos[indexPath.row]
        
        let alertVC = CFAlertViewController(title: Labels.deleteSIConfirmationTitle, message: Labels.deleteSIConfirmationMessage, textAlignment: .center, preferredStyle: .actionSheet) { (_) in
            if didConfirm {
                weak var me = self
                me?.confirmDeletation(for: surahInfo)
            }
        }
        
        let confirmAction = CFAlertAction(title: Labels.sure, style: .Destructive, alignment: .justified, backgroundColor: .alizarin, textColor: .white) { (action) in
            didConfirm = true
        }
        
        let cancelAction = CFAlertAction(title: Labels.IveChangedMyMind, style: .Cancel, alignment: .justified, backgroundColor: .concerte, textColor: .concerte) { (action) in
            
        }

        
        alertVC.addAction(confirmAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func confirmDeletation(for surahInfo: SQSurahInfo){
        SQQuranStateManager.shared.remove(surahInfo: surahInfo)
        toggleReloading()
    }
    
    func removeSurahInfo(at index: Int){
        self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func insertSurahInfo(){
        self.collectionView.insertItems(at: [IndexPath(item: surahsInfos.count - 1, section: 0)])
    }
    
    func reload(){
        self.collectionView.reloadData()
    }
}

extension SQSurahsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 28 : 40
        
        return NSAttributedString.init(string: EmptyState.favoritesTitle, attributes: [NSAttributedString.Key.foregroundColor: Colors.title, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontSize)])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 18 : 28
        
        return NSAttributedString.init(string: EmptyState.favoritesDetails, attributes: [NSAttributedString.Key.foregroundColor: Colors.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
    }
    
    func offset(forEmptyDataSet scrollView: UIScrollView!) -> CGPoint {
        return CGPoint(x: 0, y: 45)
    }
}

extension SQSurahsViewController {
    func didRemoveSurahInfo(notification: NSNotification){
        let index = notification.userInfo?[Keys.index] as! Int
        removeSurahInfo(at: index)
    }
}

extension SQSurahsViewController: SQPickingManagerDelegate {
    func pickingManagerDidCancel() {
        
    }
    
    func pickingManager(_ pickingManager: SQPickingManager, didFinishSessionWithResult pickingResult: SQPickingResult) {
        
        
        /* Create new favorite range from that picking result.. */
        let favoriteRange = SQFavoriteRange.favoriteRangeWithStartIndex(pickingResult.beginAyahIndex, endIndex: pickingResult.endAyahIndex)
        let surahInfo = SQQuranStateManager.shared.surahInfo(for: SQQuranReader.shared.surah(at: pickingResult.surahIndex), shouldGenerate: true)!
        surahInfo.add(favoriteRange: favoriteRange)

        SQQuranStateManager.shared.save()
        
        self.pickingManager = nil
    }
    
    func pickingManager(_ pickingManager: SQPickingManager, completedAyatIndexesForSurahAtIndex surahIndex: Int) -> [Int] {
        let surah = SQQuranReader.shared.surah(at: surahIndex)
        if let surahInfo = SQQuranStateManager.shared.surahInfo(for: surah!) {
            return surahInfo.completedAyahs as! [Int]
        }
        
        return []
    }
}
