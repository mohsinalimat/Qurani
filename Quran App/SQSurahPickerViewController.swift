//
//  SQSurahPickerViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/3/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import CFAlertViewController

private let kUnlockedSurahColor = UIColor.globalTint
private let kSelectedCellBG = UIColor.clouds
private let kLockedSurahColor = UIColor.concerte.withAlphaComponent(0.5)

protocol SQSurahPickerViewControllerDelegate: NSObjectProtocol {
    
    /* called when the user selects item in the list */
    func surahPickerViewController(pickerViewController: SQSurahPickerViewController, didSelectItemAtIndex index: Int)
    
    /* controls wether to lock or unlock item at specific index*/
    func surahPickerViewController(pickerViewController: SQSurahPickerViewController, shouldLockItemAtIndex index: Int) -> Bool
    
}

class SQSurahPickerViewController: SQPickerViewController {
    
    //MARK: Vars
    var surahs: [SQSurah]! = SQQuranReader.shared.surahs
    var selectedIndex: Int = -1
    
    var expandedSurahsIDs: [String]! = []
    var downloadingSurahsIDs: [String]! = []
    
    var downloadManager = SQDownloadManager.default

    weak var delegate: SQSurahPickerViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!

    //MARK: Loading
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.index = 0
        self.detailsLabel.textColor = Colors.tint
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSNotification.Name.didBuyFullPack), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 120
        
        downloadManager.delegate = self
        
        for download in (downloadManager.downloadingItems + downloadManager.pendingItems){
            self.downloadingSurahsIDs.append(download.id)
            self.expandedSurahsIDs.append(download.id)
        }
        
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func cancel(){
        dismiss()
    }
}

extension SQSurahPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surahs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let surah = surahs[indexPath.row]

        if self.expandedSurahsIDs.contains(surah.id){
            let cell = tableView.dequeueReusableCell(withIdentifier: "downloadingCell", for: indexPath) as! SQSurahDownloadTableViewCell
            
            /* customize downloading cell :D */
            cell.titleLabel.text = surah.name
            
            if downloadingSurahsIDs.contains(surah.id){
                if let download = downloadManager.download(with: surah.id), download.isPaused {
                    cell.set(state: .paused, animated: false)
                } else {
                    cell.set(state: .downloading, animated: false)
                }
            } else if expandedSurahsIDs.contains(surah.id){
                cell.set(state: .unstarted, animated: false)
            }
            
            if let surahDownload = self.downloadManager.download(with: surah.id) {
                cell.progressView.progress = Float(surahDownload.progress)
            } else {
                cell.progressView.progress = 0
            }
            
            cell.onCancelButtonTap = { [weak self] in
                self?.cancelDownloading(forSurahAt: indexPath)
            }
            
            cell.onDownloadButtonTap = { [weak self] in
                switch cell.state {
                case .unstarted:
                    self?.beginDownloading(surahAt: indexPath)
                    break
                case .paused:
                    self?.resumeDownloading(forSurahAt: indexPath)
                    break
                case .downloading:
                    self?.pauseDownloading(forSurahAt: indexPath)
                    break
                }
            }
            
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SQSurahTableViewCell

        
        let isUnlocked = !(self.delegate?.surahPickerViewController(pickerViewController: self, shouldLockItemAtIndex: indexPath.row))!
        let isDownloaded = canPlay(surah: surah)

        cell.titleLabel.textColor = isUnlocked ? Colors.tint : Colors.lightGray.withAlphaComponent(0.7)
        cell.titleLabel.text = surah.name
        cell.lockImageView.tintColor = Colors.lightGray.withAlphaComponent(0.7)
        cell.lockImageView.isHidden = isUnlocked
       
        
        var subtitle = ""
        if isUnlocked && !isDownloaded {
            subtitle = "السورة غير محمّلة"
        }
        
        cell.subtitleLabel.text = subtitle
        cell.subtitleLabel.isHidden = subtitle == ""

        cell.onDownloadButtonTap = { [unowned self] in
            self.beginDownloading(surahAt: indexPath)
        }

        
        let bgView = UIView()
        bgView.backgroundColor = Colors.tint.withAlphaComponent(0.2)
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let surah = self.surahs[indexPath.row]
        
        let isUnlocked = !(self.delegate?.surahPickerViewController(pickerViewController: self, shouldLockItemAtIndex: indexPath.row))!
        let canPlaySurah = canPlay(surah: surah)
        
        if canPlaySurah {
            self.delegate?.surahPickerViewController(pickerViewController: self, didSelectItemAtIndex: indexPath.row)
            return
        } else if !canPlaySurah && !isUnlocked {
            self.delegate?.surahPickerViewController(pickerViewController: self, didSelectItemAtIndex: indexPath.row)
            return
        }
        
        

        // if non of them contains the selected surah.. that means it is 1. not downloading, and 2. the user did not expand it.. so expand it :D
        if !expandedSurahsIDs.contains(surahs[indexPath.row].id) && !downloadingSurahsIDs.contains(surahs[indexPath.row].id){
            expand(surahAt: indexPath)
            
            // another case where the surah is expanded but not yet downloading,, so unexpand it.
        } else if expandedSurahsIDs.contains(surahs[indexPath.row].id) && !downloadingSurahsIDs.contains(surahs[indexPath.row].id) {
            unexpand(surahAt: indexPath)
        }
    }
}

extension SQSurahPickerViewController {
    func expand(surahAt indexPath: IndexPath){
        self.expandedSurahsIDs.append(self.surahs[indexPath.row].id)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func unexpand(surahAt indexPath: IndexPath){
        if let index = expandedSurahsIDs.index(of: self.surahs[indexPath.row].id){
            self.expandedSurahsIDs.remove(at: index)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    func beginDownloading(surahAt indexPath: IndexPath){
        let surah = self.surahs[indexPath.row]
        self.downloadingSurahsIDs.append(surah.id)

        downloadManager.addDownload(for: surah.index - 1)
        let download = downloadManager.download(with: surah.id)!

        download.prepare()
        download.resume()
    }
    
    func pauseDownloading(forSurahAt indexPath: IndexPath){
        if let download = self.downloadManager.download(with: self.surahs[indexPath.row].id){
            download.pause()
        }
    }
    
    func resumeDownloading(forSurahAt indexPath: IndexPath){
        if let download = self.downloadManager.download(with: self.surahs[indexPath.row].id){
            download.resume()
        }
    }
    
    func cancelDownloading(forSurahAt indexPath: IndexPath){
        if let download = self.downloadManager.download(with: self.surahs[indexPath.row].id){
            download.cancel()
        }
    }
    
    func updateProgress(forSurahAt indexPath: IndexPath){
        if let cell = self.tableView.cellForRow(at: indexPath) as? SQSurahDownloadTableViewCell, let download = self.downloadManager.download(with: self.surahs[indexPath.row].id) {
            cell.progressView.progress = Float(download.progress)
        }
    }
}

extension SQSurahPickerViewController: SQDownloadManagerDelegate {
    func downloadManager(dm: SQDownloadManager, didCancelItems items: [SQDownloadManager.Download]) {
        for item in items {
            let surah = self.surahs[item.index - 1]
            
            if let downloadingSurahIDIndex = downloadingSurahsIDs.index(of: surah.id) {
                self.downloadingSurahsIDs.remove(at: downloadingSurahIDIndex)
            }
            
            if let expandedSurahIDIndex = expandedSurahsIDs.index(of: surah.id) {
                self.expandedSurahsIDs.remove(at: expandedSurahIDIndex)
            }
            
            self.tableView.reloadRows(at: [IndexPath(row: item.index - 1, section: 0)], with: .fade)
        }
    }
    
    func downloadManager(dm: SQDownloadManager, didPauseItems items: [SQDownloadManager.Download]) {
        for item in items {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: item.index - 1, section: 0)) as? SQSurahDownloadTableViewCell {
                cell.set(state: .paused, animated: true)
            }
        }
    }
    
    func downloadManager(dm: SQDownloadManager, didResumeItems items: [SQDownloadManager.Download]) {
        for item in items {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: item.index - 1, section: 0)) as? SQSurahDownloadTableViewCell {
                cell.set(state: .downloading, animated: true)
            }
        }
    }
    
    func downloadManager(dm: SQDownloadManager, didChangeProgressFor download: SQDownloadManager.Download) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: download.index - 1, section: 0)) as? SQSurahDownloadTableViewCell {
            cell.progressView.progress = Float(download.progress)
        }
    }
    
    func downloadManager(dm: SQDownloadManager, didFinishDownloading download: SQDownloadManager.Download) {
        let surah = self.surahs[download.index - 1]
        
        if let downloadingSurahIDIndex = downloadingSurahsIDs.index(of: surah.id) {
            self.downloadingSurahsIDs.remove(at: downloadingSurahIDIndex)
        }
        
        if let expandedSurahIDIndex = expandedSurahsIDs.index(of: surah.id) {
            self.expandedSurahsIDs.remove(at: expandedSurahIDIndex)
        }
        
        
        self.tableView.reloadRows(at: [IndexPath(row: download.index - 1, section: 0)], with: .fade)
    }
}
