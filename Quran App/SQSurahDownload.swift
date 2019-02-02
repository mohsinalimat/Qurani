//
//  SQNetworkingManager.swift
//  Quran App
//
//  Created by Hussein Ryalat on 10/17/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation
import Alamofire

@objc protocol SQSurahDownloadDelegate: class {
   
    @objc optional func downloadGroup(group: SQSurahDownload, didChangeProgress progress: Double)
    
    @objc optional func downloadGroupDidPause(group: SQSurahDownload)
    
    @objc optional func downloadGroupDidResume(group: SQSurahDownload)
    
    @objc optional func downloadGroupDidCancel(group: SQSurahDownload)
    
    @objc optional func downloadGroupDidFinish(group: SQSurahDownload)
}

class SQSurahDownload: NSObject {
    
    //MARK: Class Helper methods
    
    /* Generate a group id, this typically consist of 3 numbers.. */
    class func id(for index: Int) -> String {
        return SQSurah.id(for: index)
    }
    
    class func itemIDs(count: Int, groupIndex: Int) -> [String]{
        var ids: [String] = []
        for i in 1..<count + 1 {
            ids.append( SQDownloadItem.id(for: i, at: groupIndex) )
        }
        
        return ids
    }
    
    class func itemIDs(indexes: [Int], groupIndex: Int) -> [String] {
        var ids: [String] = []
        for index in indexes {
            ids.append(SQDownloadItem.id(for: index, at: groupIndex))
        }
        
        return ids
    }
    
    //MARK: Variables
    
    weak var delegate: SQSurahDownloadDelegate?
    
    private(set) var index: Int
    private(set) var printsDebuggingLog = true
    
    var numberOfSimultaneousDownloads: Int {
        return max(5, totalItemsCount / 10)
    }
    
    var progress: Double {
        return Double(downloadedIndexes.count + skipIndexes.count) / Double(totalItemsCount)
    }

    /* Tracking.. */
    fileprivate(set) var currentIndex = 0
    fileprivate(set) var downloadedItemsCount: Int = 0
    fileprivate(set) var totalItemsCount: Int = 0
    
    /* Items that are already exist, and should not be downloaded */
    fileprivate(set) var skipIndexes: [Int] = []
    
    /* any downloaded item will be here, so we can write it to the mainfist */
    fileprivate(set) var downloadedIndexes: [Int] = []
    
    /* flags, private */
    fileprivate var _hasStarted = false
    fileprivate var _shouldStop = false
    fileprivate var _paused = true
    
    /* read only, main info about the download */
    private(set) var id: String
    private(set) var sourceBaseURL: URL
    private(set) var destinationURL: URL
    
    var isPaused: Bool {
        return _paused
    }
    
    //MARK: Downloads
    
    fileprivate(set) var downloadingItems: [SQDownloadItem] = []
    
    //MARK: Initialization
    
    init(index: Int, total: Int){
        self.index = index
        self.totalItemsCount = total
        
        
        self.id = SQSurahDownload.id(for: index)
        self.sourceBaseURL = SQSourceBaseURL
        self.destinationURL = SQDestinationBaseURL.appendingPathComponent(self.id, isDirectory: true)
        
        super.init()
    }
    
    func prepare(){
        /* create the containing folder if it does not exist.. */
        _printLine()
        _print("PREPARING..")
        _print("DESTINATION: \(self.destinationURL)")
        
        // the falgs helps the download check if it should do manual check
        let flags = SQDownloadUserDefaultsManager.shared.flags(for: self.id)
        
        
        /* check if the folder exist */
        if !FileManager.default.fileExists(atPath: destinationURL.path){
            _print("DOWNLOADING SURAH FOR THE FIRST TIME..")
            self.skipIndexes = []
            return
        }
        
        /* read the info and use it's contents if found, ensuring the info is up to date.. */
        if let infoPath = SQDownloadInfo.read(id: self.id), !flags.contains(.manualCheck){
            self.skipIndexes = infoPath.contents
            _print("FOUND INFO ( UP TO DATE ), SKIP INDEXES: \(skipIndexes.sorted())")
            return
        }
        
        /* manually list files and generate the info.. */
        do {
            let urls = try FileManager.default.contentsOfDirectory(atPath: destinationURL.path).filter { return $0.hasSuffix(SQMP3Extension) }
            for url in urls {
                let index = self._index(for: String(url.dropLast(4)))
                self.skipIndexes.append(index)
            }
            
            _generateInfo()
            _print("Manual Reading, skip indexes: \(self.skipIndexes)")
            return
        } catch {
            _print("Error while scanning for info..")
            self.skipIndexes = []
        }
    }
    
    func resume(){
        if _hasStarted {
            if _paused {
                /* mark that we can add new downloads.. */
                self._paused = false
                self._shouldStop = false
                
                self.delegate?.downloadGroupDidResume?(group: self)
                
                /* resume the current downloads.. */
                for download in downloadingItems {
                    download.resume()
                }
                
                _printLine()
                _print("RESUMING WITH:\nNUMBER OF DOWNLOADING ITEMS: \(self.downloadingItems.count)\nDOWNLOADED ITEMS: \(self.downloadedItemsCount)")

                
                /* add any downloads ;D */
                self._fillDownloads()
            }
            
            return
        }
        
        _printLine()
        _print("STARTING DOWNLOAD..")
        
        if self.progress == 1 {
            _doUponFinish()
            return
        }
        
        _hasStarted = true
        _paused = false
        self.delegate?.downloadGroupDidResume?(group: self)
        self._fillDownloads()
    }
    
    func pause(){
        /* mark that we don't have to add new downloads.. */
        _shouldStop = true
        _paused = true
        
        /* pause the current downloads.. */
        for download in downloadingItems {
            download.pause()
        }
        
        _printLine()
        _print("PAUSING WITH:\nNUMBER OF DOWNLOADING:\(self.downloadingItems.count)\nDOWNLOADED ITEMS: \(self.downloadedItemsCount)")
        
        _generateInfo()
        delegate?.downloadGroupDidPause?(group: self)
    }
    
    func cancel(){
        _shouldStop = true
        _paused = true
        
        for download in downloadingItems {
            download.delegate = nil
            download.cancel()
        }
        
        _printLine()
        _print("CANCELING WITH:\nDOWNLOADING ITEMS: \(self.downloadingItems.count)\nDOWNLOADED ITEMS: \(self.downloadedItemsCount)")
        
        /* removing allllll items.. */
        self.downloadingItems.removeAll()
        
        /* remove the containing folder.. */
        do {
            try FileManager.default.removeItem(at: self.destinationURL)
        } catch {
            // the folder contaning the ayat sound files couldn't be deleted, in that case just save the info for later user.
            _generateInfo()
        }
        
        delegate?.downloadGroupDidCancel?(group: self)
    }
    

}

//MARK: Private
fileprivate extension SQSurahDownload {
    fileprivate func _printLine(){
        _print("*********************")
    }
    
    fileprivate func _print(_ str: String){
        if printsDebuggingLog {
            print("\(self.id): " + str)
        }
    }
    
    fileprivate func _index(for id: String) -> Int {
        /* 1. skip the first three characters.. */
        let first3 = String(id.dropFirst(3))
        
        /* 2. remove any zeros.. */
        var finalString = first3
        for c in first3 {
            if c == "0" {
                finalString = String(finalString.dropFirst())
            } else {
                break
            }
        }
        
        /* 3. generate Integer */
        let int = Int(finalString)
        return int ?? -1
    }
    
    func _generateInfo(){
        let info = SQDownloadInfo(id: self.id)
        
        info.contents = self.downloadedIndexes + self.skipIndexes
        info.isThereSomethingMissed = !(self.downloadedIndexes.count + self.skipIndexes.count == self.totalItemsCount)
        
        info.write()
    }
    
    fileprivate func _generateItem(with index: Int) -> SQDownloadItem {
        let id = SQDownloadItem.id(for: index, at: self.index)
        let item = SQDownloadItem(id: id, sourceBaseURL: self.sourceBaseURL, destinationBaseURL: self.destinationURL)
        item.delegate = self
        
        return item
    }
    
    fileprivate func _nextIndex(for index: Int) -> Int {
        var nextIndex = index + 1
        while nextIndex <= self.totalItemsCount{
            if skipIndexes.contains(nextIndex) {
                nextIndex += 1
                continue
            }
            
            return nextIndex
        }
        
        /* no available index to download.. */
        return -1
    }

    
    fileprivate func _startNewDownload(){
        /* 1. checks if there is available indexes to download.. */
        guard self._canAddDownloads() else {
            return
        }
        
        /* 2. creates a new item from the next index.. */
        let nextIndex = _nextIndex(for: currentIndex)
        let item = _generateItem(with: nextIndex)
        
        self.currentIndex = nextIndex
        
        self.downloadingItems.append(item)
        item.delegate = self
        item.download()
        item.index = nextIndex
        
        _print("Downloading -> \(item.id)")
    }
    
    fileprivate func _canAddDownloads() -> Bool {
        return self._nextIndex(for: self.currentIndex) != -1
    }
    
    fileprivate func _fillDownloads(){
        for _ in 0..<numberOfSimultaneousDownloads {
            if self.downloadingItems.count <= numberOfSimultaneousDownloads {
                self._startNewDownload()
            } else {
                break
            }
        }
    }
    
    fileprivate func _doUponFinish(){
        _printLine()
        _print("DOWNLOADING FINISHED:\nDESTINATION: \(self.destinationURL)\nTOTAL ITEMS: \(self.totalItemsCount)")
        _printLine()
        _generateInfo()
        self.delegate?.downloadGroupDidFinish?(group: self)
    }
}

extension SQSurahDownload: SQDownloadItemDelegate {
    func downloadItem(item: SQDownloadItem, didFinishWithError error: Error?) {
        
        // a new item has been downloaded but the state ( plist file ) has not yet been modifited to include the downloaded file, so set the flag to 'manualCheck' for just in case.
        SQDownloadUserDefaultsManager.shared.set(flags: [.manualCheck], for: self.id)

        guard let index = self.downloadingItems.index(of: item) else {
            return
        }
        
        if let error = error {
            _print("ERROR DOWNLOADING -> \(item.id)")
            print("SURAH DOWNLOAD ERROR \(self.id): \(error.localizedDescription)")
            self.skipIndexes.append(item.index)
        } else {
            self.downloadedIndexes.append(item.index)
            item.delegate = nil
            _print("FINISHED -> \(item.id)")
        }
        
        
        self.downloadingItems.remove(at: index)
        
        self.delegate?.downloadGroup?(group: self, didChangeProgress: self.progress)

        _print("PROGRESS: \(progress * 100)%")
        if downloadedIndexes.count + skipIndexes.count == self.totalItemsCount {
            self._doUponFinish()
        }
        
        /* automaticly start new download.. because we removed one item from the queue.. */
        if !_shouldStop {
            _startNewDownload()
        }
    }
}

