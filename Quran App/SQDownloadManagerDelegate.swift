//
//  SQDownloadManagerDelegate.swift
//  Quran App
//
//  Created by Hussein Ryalat on 11/18/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

protocol SQDownloadManagerDelegate: class {
    
    func downloadManager(dm: SQDownloadManager, willBeginDownloading download: SQDownloadManager.Download)
    
    
    func downloadManager(dm: SQDownloadManager, didFinishDownloading download: SQDownloadManager.Download)
    
    
    func downloadManager(dm: SQDownloadManager, didChangeProgressFor download: SQDownloadManager.Download)
    
    
    func downloadManager(dm: SQDownloadManager, didResumeItems items: [SQDownloadManager.Download])
    
    
    func downloadManager(dm: SQDownloadManager, didPauseItems items: [SQDownloadManager.Download])
    
    func downloadManager(dm: SQDownloadManager, didCancelItems items: [SQDownloadManager.Download])

}


extension SQDownloadManagerDelegate {
    func downloadManager(dm: SQDownloadManager, willBeginDownloading download: SQDownloadManager.Download){}
    
    func downloadManager(dm: SQDownloadManager, didFinishDownloading download: SQDownloadManager.Download){}
    
    func downloadManager(dm: SQDownloadManager, didChangeProgressFor download: SQDownloadManager.Download){}
    
    func downloadManager(dm: SQDownloadManager, didResumeItems: [SQDownloadManager.Download]){}
    
    func downloadManager(dm: SQDownloadManager, didPauseItems: [SQDownloadManager.Download]){}
    
    func downloadManager(dm: SQDownloadManager, didCancelItems items: [SQDownloadManager.Download]){}
}
