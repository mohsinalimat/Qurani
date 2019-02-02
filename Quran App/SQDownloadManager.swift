//
//  SQDownloadManager.swift
//  Quran App
//
//  Created by Hussein Ryalat on 11/11/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation



class SQDownloadManager {
    
    /* we are responsable for downloading surahs.. */
    typealias Download = SQSurahDownload
    
    /* well, it uses the base URL's, both source and destination*/
    static let `default` = SQDownloadManager()
    
    /* notifies this object of any changes happen :D */
    weak var delegate: SQDownloadManagerDelegate?
    
    fileprivate var _hasStarted = false
    fileprivate var _shouldStop = false
    fileprivate var _isPaused = true
    
    /* Base URL's */
    private(set) var sourceBaseURL: URL
    private(set) var destinationBaseURL: URL
    
    /* Downloads Management */
    fileprivate(set) var pendingItems: [Download] = []
    fileprivate(set) var downloadingItems: [Download] = []
    
    var numberOfSimultaneousDownloads = 4

    init(){
        self.sourceBaseURL = SQSourceBaseURL
        self.destinationBaseURL = SQDestinationBaseURL
    }
    
    func download(with id: String) -> Download? {
        for download in (downloadingItems + pendingItems) {
            if download.id == id {
                return download
            }
        }; return nil
    }
    
    
    /* convenience method for adding download based on surah.. */
    func addDownload(for surahIndex: Int){
        if let surah = SQQuranReader.shared.surah(at: surahIndex){
            let download = SQSurahDownload(index: surah.index, total: surah.ayat.count)
            self.add(download: download)
        }
    }
    
    func add(download: Download){
        if self.download(with: download.id) != nil {
            return
        }
        
        download.delegate = self
        
        if _hasStarted {
            download.prepare()
            download.resume()
        } else {
            self.pendingItems.append(download)
        }
    }
    
    
    
    func pauseAll(){
        for download in self.downloadingItems {
            download.pause()
        }
    }
    
    func resumeAll(){
        if _isPaused && _hasStarted {
            self._isPaused = false
            
            for download in self.downloadingItems {
                download.resume()
            }
            
            return
        }
        
        self._hasStarted = true
        self._isPaused = false
        
        _fillDownloads()
    }
    
    fileprivate func _startNewDownload(){
        if !_canAddDownloads() {
            return
        }
        
        if let itemPending = self.pendingItems.first {
            itemPending.prepare()
            itemPending.resume()
        }
    }
    
    fileprivate func _canAddDownloads() -> Bool {
        return self.downloadingItems.count < self.numberOfSimultaneousDownloads
    }
    
    fileprivate func _fillDownloads(){
        for _ in 0 ..< self.numberOfSimultaneousDownloads {
            _startNewDownload()
        }
    }
}


extension SQDownloadManager: SQSurahDownloadDelegate {
    func downloadGroupDidCancel(group: SQSurahDownload) {
        if let index = self.downloadingItems.index(of: group){
            downloadingItems.remove(at: index)
            delegate?.downloadManager(dm: self, didCancelItems: [group])
        }
    }
    
    func downloadGroupDidResume(group: SQSurahDownload) {
        if let index = self.pendingItems.index(of: group){
            pendingItems.remove(at: index)
            self.downloadingItems.append(group)
        }
        
        delegate?.downloadManager(dm: self, didResumeItems: [group])
    }
    
    func downloadGroupDidFinish(group: SQSurahDownload) {
        guard let index = self.downloadingItems.index(of: group) else {
            return
        }
        
        group.delegate = nil
        self.downloadingItems.remove(at: index)
        self.delegate?.downloadManager(dm: self, didFinishDownloading: group)
        
        /* automaticly start new download.. because we removed one item from the queue.. */
        if !_shouldStop {
            _startNewDownload()
        }
    }
    
    func downloadGroupDidPause(group: SQSurahDownload) {
        self.delegate?.downloadManager(dm: self, didPauseItems: [group])
    }
    
    func downloadGroup(group: SQSurahDownload, didChangeProgress progress: Double) {
        self.delegate?.downloadManager(dm: self, didChangeProgressFor: group)
    }
}
