//
//  SQDownloadConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 10/20/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

private let alAfasyURL = URL(string: "http://www.everyayah.com/data/Alafasy_128kbps/")!
private let alDussary = URL(string: "http://www.everyayah.com/data/Yasser_Ad-Dussary_128kbps/")!

let SQSourceBaseURL = alDussary
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
