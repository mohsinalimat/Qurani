//
//  SQInputSession.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/10/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import CFAlertViewController


@objc protocol SQPickingManagerDelegate: NSObjectProtocol {
    
    func pickingManager(_ pickingManager: SQPickingManager, didFinishSessionWithResult pickingResult: SQPickingResult)
   
    func pickingManager(_ pickingManager: SQPickingManager, completedAyatIndexesForSurahAtIndex surahIndex: Int) -> [Int]
    
    
    @objc optional func pickingManagerDidCancel()
}

class SQPickingManager: NSObject {
    
    fileprivate(set) var selectedSurahIndex: Int = -1 {
        didSet {
            selectedBeginAyahIndex = -1
            selectedEndAyahIndex = -1
        }
    }
    
    fileprivate(set) var selectedBeginAyahIndex: Int = -1
    fileprivate(set) var selectedEndAyahIndex: Int = -1
    
    var currentStep: SQPickingStep! = .undefined
    
    weak var delegate: SQPickingManagerDelegate?
    
    private(set) var navigationController: UINavigationController?
    
    var completedAyatDictionary: [Int: [Int]] = [:]
    
    lazy var stuffUnlocked: Bool = {
        return UserDefaults.standard.bool(forKey: SettingsKeys.DidBuyPack)
    }()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSNotification.Name.didBuyFullPack), object: nil, queue: OperationQueue.main) { (_) in
            self.stuffUnlocked = true
        }
    }

    deinit {
        navigationController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewControllerForStep(_ step: SQPickingStep) -> UIViewController? {
        switch step {
        case .selectingSurah:
            let surahPicker = SQSurahPickerViewController.create(from: "Picking", withIdentifier: "SurahPicker")
            surahPicker?.selectedIndex = selectedSurahIndex
            surahPicker?.pickerTitle = PickingConstants.SurahPicker.Title
            surahPicker?.pickerDetails = PickingConstants.SurahPicker.Subtitle
            surahPicker?.delegate = self
            
            return surahPicker
        case .selectingBeginAyah:
            if selectedSurahIndex == -1 {
                return nil
            }
            let ayahPicker = SQAyahPickerViewController.create(from: "Picking", withIdentifier: "AyahPicker")
            ayahPicker?.selectedIndex = selectedBeginAyahIndex
            ayahPicker?.surah = SQQuranReader.shared.surah(at: selectedSurahIndex)
            ayahPicker?.pickingMode = .startIndex
            ayahPicker?.pickerTitle = PickingConstants.BeginIndexPicker.Title
            ayahPicker?.pickerDetails = PickingConstants.BeginIndexPicker.Subtitle
            ayahPicker?.delegate = self
            ayahPicker?.beginSelectionIndex = -1
            ayahPicker?.completedIndexes = self.completedAyatDictionary[selectedSurahIndex]!
            
            return ayahPicker
        case .selectingEndAyah:
            if selectedSurahIndex == -1 || selectedBeginAyahIndex == -1 {
                return nil
            }
            
            let ayahPicker = SQAyahPickerViewController.create(from: "Picking", withIdentifier: "AyahPicker")
            ayahPicker?.selectedIndex = selectedEndAyahIndex
            ayahPicker?.surah = SQQuranReader.shared.surah(at: selectedSurahIndex)
            ayahPicker?.pickingMode = .endIndex
            ayahPicker?.pickerTitle = PickingConstants.EndIndexPicker.Title
            ayahPicker?.pickerDetails = PickingConstants.EndIndexPicker.Subtitle
            ayahPicker?.beginSelectionIndex = self.selectedBeginAyahIndex
            ayahPicker?.delegate = self
            ayahPicker?.completedIndexes = self.completedAyatDictionary[selectedSurahIndex]!
            
            
            return ayahPicker
        case .completing:
            if selectedSurahIndex == -1 || selectedBeginAyahIndex == -1 || selectedEndAyahIndex == -1 {
                return nil
            }
            
            let completionViewController = SQCompletionViewController.create(from: "Picking", withIdentifier: "completion")
            completionViewController?.surah = SQQuranReader.shared.surah(at: selectedSurahIndex)
            completionViewController?.beginAyahIndex = selectedBeginAyahIndex
            completionViewController?.endAyahIndex = selectedEndAyahIndex
            completionViewController?.delegate = self
            
            return completionViewController
        default:
            return nil
        }
    }
    
    func initialViewController() -> UIViewController! {
        let surahPicker = self.viewControllerForStep(.selectingSurah)
        
        navigationController = UINavigationController(rootViewController: surahPicker!)
        navigationController!.isNavigationBarHidden = true
        
        
        return navigationController
    }
    
    fileprivate func showStore(above viewController: UIViewController){
        viewController.performSegue(withIdentifier: "store", sender: viewController)
    }
    
    fileprivate func showUnlockAlert(above viewController: UIViewController){
        var shouldGoStore = false
        weak var me = self
        
        
        let alertController = CFAlertViewController(title: Labels.unlockAlertTitle, message: Labels.unlockAlertDescription, textAlignment: .center, preferredStyle: .alert) { (_) in
            if shouldGoStore {
                me?.showStore(above: viewController)
            }
        }

        
        let yesAction = CFAlertAction(title: Labels.yes, style: .Default, alignment: .justified, backgroundColor: .emerald, textColor: .white) { (action) in
            shouldGoStore = true
        }
        
        let noAction = CFAlertAction(title: Labels.noThanks, style: .Cancel, alignment: .justified, backgroundColor: .lightGray, textColor: .lightGray) { (action) in
            
        }
        
        for action in [yesAction, noAction] {
            alertController.addAction(action)
        }
        
        alertController.shouldDismissOnBackgroundTap = true
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func indexIsLocked(index: Int) -> Bool {
        return stuffUnlocked ? false : !kAvailableIndexes.contains(index)
    }
}

extension SQPickingManager: SQSurahPickerViewControllerDelegate {
    func surahPickerViewController(pickerViewController: SQSurahPickerViewController, shouldLockItemAtIndex index: Int) -> Bool {
        return indexIsLocked(index: index + 1)
    }
    
    func surahPickerViewController(pickerViewController: SQSurahPickerViewController, didSelectItemAtIndex index: Int) {
        if indexIsLocked(index: index + 1) {
            pickerViewController.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
            showUnlockAlert(above: pickerViewController)
            return
        }
        
        selectedSurahIndex = index
        pickerViewController.selectedIndex = index
        
        if self.completedAyatDictionary[selectedSurahIndex] == nil {
            if let completedIndexes = self.delegate?.pickingManager(self, completedAyatIndexesForSurahAtIndex: selectedSurahIndex) {
                self.completedAyatDictionary[selectedSurahIndex] = completedIndexes
            }
        }
        
        let next = self.viewControllerForStep(.selectingBeginAyah)
        self.navigationController?.pushViewController(next!, animated: true)
    }
}

extension SQPickingManager: SQAyahPickerViewControllerDelegate {
    func ayahPickerViewController(picker: SQAyahPickerViewController, didSelectItemAtIndex index: Int) {
        if picker.pickingMode == .startIndex {
            self.selectedBeginAyahIndex = index
            picker.selectedIndex = index
            
            let next = self.viewControllerForStep(.selectingEndAyah)
            self.navigationController?.pushViewController(next!, animated: true)
            
            return
        }
        
        self.selectedEndAyahIndex = index
        picker.selectedIndex = index
        
        let next = self.viewControllerForStep(.completing)
        self.navigationController?.pushViewController(next!, animated: true)
    }
}

extension SQPickingManager: SQCompletionViewControllerDelegate {
    func completionViewController(viewController: SQCompletionViewController, shouldProceed shouldSave: Bool) {
        if shouldSave {
            let pickingResult = SQPickingResult(surahIndex: self.selectedSurahIndex, beginAyahIndex: self.selectedBeginAyahIndex + 1, endAyahIndex: self.selectedEndAyahIndex)
            self.delegate?.pickingManager(self, didFinishSessionWithResult: pickingResult)
            viewController.dismiss(animated: true, completion: nil)
            
            return
        }
        
        self.delegate?.pickingManagerDidCancel?()
        self.navigationController?.dismiss()
    }
}


extension SQPickingManager {
    class func unlockAllContent(){
        UserDefaults.standard.set(true, forKey: SettingsKeys.DidBuyPack)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.didBuyFullPack), object: nil, userInfo: [:])
    }
}
