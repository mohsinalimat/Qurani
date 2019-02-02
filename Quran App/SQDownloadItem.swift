//
//  SQDownloadItem.swift
//  Quran App
//
//  Created by Hussein Ryalat on 10/18/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation
import Alamofire



enum SQDownloadStatus {
    case suspended, downloading, finished, pending
}

@objc protocol SQDownloadItemDelegate: class {
    
    /* when begins downloading.. */
    @objc optional func downloadItemWillBeginDownloading(item: SQDownloadItem)
    
    /* while downloading.. */
    @objc optional func downloadItem(item: SQDownloadItem, didChangeProgress progress: Foundation.Progress)
    
    /* when finishes downloading, with or without error.. */
    @objc optional func downloadItem(item: SQDownloadItem, didFinishWithError error: Error?)
}

class SQDownloadItem: NSObject {
    
    /* generates 6 numbers string representing the id.. */
    class func id(for index: Int, at groupIndex: Int) -> String {
        return SQAyah.id(for: index, inSurah: groupIndex)
    }
    

    //MARK: Variables

    var index: Int = -1
    
    private(set) var id: String
    private(set) var destinationURL: URL
    private(set) var sourceURL: URL
    
    private(set) var downloadDestination: DownloadRequest.DownloadFileDestination!

    private(set) var isPaused = true
    
    weak var delegate: SQDownloadItemDelegate?
    
    private var _request: DownloadRequest?
    
    init(id: String, sourceBaseURL: URL, destinationBaseURL: URL){
        self.id = id
        self.destinationURL = destinationBaseURL.appendingPathComponent(id).appendingPathExtension(SQMP3Extension)
        self.sourceURL = sourceBaseURL.appendingPathComponent(id).appendingPathExtension(SQMP3Extension)
        
        super.init()
        downloadDestination = { (temporaryURL, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            
            return (self.destinationURL, [.createIntermediateDirectories, .removePreviousFile])
        }
    }
    
    func download(){
        self.delegate?.downloadItemWillBeginDownloading?(item: self)
        self.isPaused = false
        self._request = Alamofire.download(self.sourceURL, to: downloadDestination).downloadProgress { (progress) in
            self.delegate?.downloadItem?(item: self, didChangeProgress: progress)
            }.response { [unowned self] (response) in
                self.isPaused = true
                self.delegate?.downloadItem?(item: self, didFinishWithError: response.error)
        }
    }
    
    func resume(){
        self.isPaused = false
        _request?.resume()
    }
    
    func pause(){
        self.isPaused = true
        _request?.suspend()
    }
    
    func cancel(){
        self.isPaused = true
        _request?.cancel()
    }
}
