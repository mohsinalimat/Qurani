//
//  SQFavoritedRangesViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/29/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import CFAlertViewController

class SQFavoritedRangesViewController: SQViewController {
        
    var currentFavoriteRangeIdentifier: String? {
        return SQSoundManager.default.queueIdentifier
    }
    
    var surahInfo: SQSurahInfo!
    
    fileprivate(set) var completedFavoritedRanges: [SQFavoriteRange] = []
    fileprivate(set) var uncompletedFavroitedRanges: [SQFavoriteRange] = []
    
    var favoritedRanges: [SQFavoriteRange]! {
        return uncompletedFavroitedRanges + completedFavoritedRanges
    }
    
    fileprivate var alertPresentation: Bool = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    var cellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .phone ? 80 : 120
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.surahInfo == nil {
            fatalError("Opening a favorited ranges view controller without specifing surahInfo!")
        }
        
        isHeroEnabled = true
        collectionView.heroModifiers = [.cascade]
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
                
        titleLabel.textColor = Colors.title
        detailsLabel.textColor = Colors.lightGray
        
        editButton.tintColor = Colors.tint
        doneButton.tintColor = Colors.tint
        backButton.tintColor = Colors.tint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViews()
        alertPresentation = false
        separateArrays()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isEditing && !alertPresentation {
            setEditing(false, animated: true)
        }
    }
    
    func updateViews(){
        self.view.heroID = self.surahInfo.surahName! + "Cell"
        
        self.titleLabel.text = self.surahInfo.surahName!
        self.detailsLabel.text = self.surahInfo.surah.description

        self.detailsLabel.heroID = self.surahInfo.surahName + "Details"
        self.titleLabel.heroID = self.surahInfo.surahName! + "Title"

        self.collectionView.reloadData()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        /* change the edit button state .. */
        if !animated {
            self.doneButton.alpha = editing ? 1 : 0
            self.editButton.alpha = editing ? 0 : 1
            return
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.doneButton.alpha = editing ? 1 : 0
            self.editButton.alpha = editing ? 0 : 1
        }
        
        self.collectionView.reloadData()
    }
    
    func deleteFavoriteRange(_ favoriteRange: SQFavoriteRange){
        /* Display a confirmation alert */
        var didConfirm = false
        alertPresentation = true
        
        let alertVC = CFAlertViewController(title: Labels.deleteFRConfirmationTitle, message: Labels.deleteFRConfirmationMessage, textAlignment: .center, preferredStyle: .alert) { (_) in
            if didConfirm {
                weak var me = self
                me?.confirmDeletation(for: favoriteRange)
            }
        }
        
        let confirmAction = CFAlertAction(title: Labels.sure, style: .Destructive, alignment: .justified, backgroundColor: .alizarin, textColor: .white) { (_) in
            didConfirm = true
        }
        
        let cancelAction = CFAlertAction(title: Labels.IveChangedMyMind, style: .Cancel, alignment: .justified, backgroundColor: .concerte, textColor: .concerte) { (_) in
            
        }
        
        
        alertVC.addAction(confirmAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func confirmDeletation(for favoriteRange: SQFavoriteRange){
        if SQSoundManager.default.queueIdentifier == favoriteRange.identifier {
            SQSoundManager.default.itemsQueue = nil
        }
        
        var section: Int = 0
        var index: Int = 0
        
        if self.completedFavoritedRanges.contains(favoriteRange){
            section = 1
            index = completedFavoritedRanges.index(of: favoriteRange)!
            completedFavoritedRanges.remove(at: index)
        } else {
            index = uncompletedFavroitedRanges.index(of: favoriteRange)!
            uncompletedFavroitedRanges.remove(at: index)
        }
        
        surahInfo.remove(favoriteRange: favoriteRange)
        
        weak var me = self
        self.collectionView.performBatchUpdates({
            if self.completedFavoritedRanges.count == 0 && section == 1 {
                me?.collectionView.deleteSections(IndexSet(integer: 0))
            } else {
                me?.collectionView.deleteItems(at: [IndexPath(row: index, section: section)])
            }
        }) { (finished) in
            if me?.surahInfo.favoritedRanges.count == 0 {
                /* remove the surahInfo too! */
                SQQuranStateManager.shared.remove(surahInfo: (me?.surahInfo)!)
                me?.dismiss()
            }
        }
    }
    
    func favoritedRange(at indexPath: IndexPath) -> SQFavoriteRange {
        return favoritedRanges[indexPath.row]
        //return indexPath.section == 0 ? uncompletedFavroitedRanges[indexPath.row] : completedFavoritedRanges[indexPath.row]
    }
    
    private func separateArrays(){
        completedFavoritedRanges = []
        uncompletedFavroitedRanges = []
        
        let favoritedRanges = surahInfo.favoritedRanges.array as! [SQFavoriteRange]
        for favoriteRange in favoritedRanges {
            favoriteRange.progress == 1 ? completedFavoritedRanges.append(favoriteRange) : uncompletedFavroitedRanges.append(favoriteRange)
        }

    }
    
    @IBAction func back(){
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        navigationController?.popViewController(animated: true)
    }
}

extension SQFavoritedRangesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favoritedRanges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SQFavoritedRangeCollectionViewCell
        
        /* getting the right favorite range.. */
        let favoriteRange: SQFavoriteRange! = favoritedRange(at: indexPath)
        
//        cell.heroID = favoriteRange.description + "Cell"
        cell.titleLabel.heroID = favoriteRange.description + "Details"
//        cell.titleLabel.heroModifiers = [.zPosition(999)]
        

        cell.layer.borderColor = Colors.semiWhite.cgColor
        
        cell.rightView.isHidden = favoriteRange.identifier != self.currentFavoriteRangeIdentifier
        
        cell.titleLabel.text = favoriteRange.description
        cell.titleLabel.textColor = Colors.contents
        cell.rightView.backgroundColor = Colors.tint
        
        let originalState: SQFavoritedRangeCollectionViewCell.State = favoriteRange.progress < 1 ? .normal : .completed
        let state = self.isEditing ? SQFavoritedRangeCollectionViewCell.State.delete : originalState
        cell.setState(state: state, animated: false)
        cell.deleteAction = {
            weak var me = self
            me?.deleteFavoriteRange(favoriteRange)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView
            .bounds.width - 40, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SQLabelCollectionReusableView
        view.label.text = "المحددات المكتملة"
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextViewController = SQAyatViewController.create(from: "Player", withIdentifier: "Ayat")
        nextViewController?.favoriteRange = favoritedRange(at: indexPath)
        nextViewController?.isHeroEnabled = false
        
        self.navigationController?.pushViewController(nextViewController!, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let favoriteRange = favoritedRange(at: indexPath)
        if favoriteRange.new {
            cell.twinkle()
            favoriteRange.new = false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.collectionView.reloadData()
    }
    
    @IBAction func doneButtonTapped(){
        setEditing(false, animated: true)
    }
    
    @IBAction func editButtonTapped(){
        setEditing(true, animated: true)
    }
}
