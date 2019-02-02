//
//  SQDownloadInfo.swift
//  Quran App
//
//  Created by Hussein Ryalat on 11/11/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

class SQDownloadInfo {
    
    class func URL(for id: String) -> URL{
        return SQDestinationBaseURL.appendingPathComponent(id).appendingPathComponent(id).appendingPathExtension(SQPLISTExtension)
    }
    
    /* auto generated based on the id */
    lazy var url: URL = {
       return SQDownloadInfo.URL(for: self.id)
    }()
    
    /* used to determinate the file name and location.. */
    var id: String
    
    /* a fast way to know if we need to download any contents or not.. */
    var isThereSomethingMissed = false
    
    /* indexes of ayat which files are downloaded already.. */
    var contents: [Int] = []
    
    init(id: String){
        self.id = id
    }
    
    func write() {
        let dictionary = [SQDownloadInfoMissedIndexesKey: contents, SQDownloadInfoIsThereSomethingMissedKey: isThereSomethingMissed] as [String: Any]
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
            try data.write(to: url)
            
            // the info file is now up to date, no need to do manual check next time the download starts.
            SQDownloadUserDefaultsManager.shared.set(flags: [], for: self.id)
        }  catch {
            
            // there was error saving the info, so set the flag to do manual check next time the download starts.
            SQDownloadUserDefaultsManager.shared.set(flags: [.manualCheck], for: self.id)
        }
    }
    
    class func read(id: String) -> SQDownloadInfo? {
        let url = SQDestinationBaseURL.appendingPathComponent(id).appendingPathComponent(id).appendingPathExtension(SQPLISTExtension)
        if !FileManager.default.fileExists(atPath: url.path){
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                print("nil dictionary or data while reading data :D")
                return nil
            }
            
            let downloadInfo = SQDownloadInfo(id: id)
            downloadInfo.contents = dictionary[SQDownloadInfoMissedIndexesKey] as! [Int]
            downloadInfo.isThereSomethingMissed = dictionary[SQDownloadInfoIsThereSomethingMissedKey] as! Bool
            
            return downloadInfo
        } catch let error {
            print("error reading download info file.. \(error.localizedDescription)")
            return nil
        }
    }
}
