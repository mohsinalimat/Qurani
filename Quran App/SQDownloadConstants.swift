//
//  SQDownloadConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 10/20/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

let SQSourceBaseURL = URL(string: "http://everyayah.com/data/Ibrahim_Akhdar_32kbps/")!
let SQDestinationBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

let SQMP3Extension = "mp3"
let SQPLISTExtension = "plist"

let SQDownloadInfoMissedIndexesKey = "contents"
let SQDownloadInfoCurrentIndexKey = "current_index"
let SQDownloadInfoTotalItemsCountKey = "total"
let SQDownloadInfoIsThereSomethingMissedKey = "is_there_something_missed"

func ayahUrl(for ayah: SQAyah) -> URL {
    return url(for: ayah.surah).appendingPathComponent(ayah.id).appendingPathExtension(SQMP3Extension)
}

func url(for surah: SQSurah) -> URL {
    return SQDestinationBaseURL.appendingPathComponent(surah.id, isDirectory: true)
}

func canPlay(surah: SQSurah) -> Bool {
    if kAvailableIndexes.contains(surah.index){
        return true
    }
    
    guard let info = SQDownloadInfo.read(id: surah.id) else {
        return false
    }
    
    return !info.isThereSomethingMissed
}

func canPlay(ayah: SQAyah) -> Bool {
    return FileManager.default.fileExists(atPath: ayahUrl(for: ayah).path)
}
