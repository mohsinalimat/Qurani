//
//  SQQuranReader.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

class SQQuranReader {
    
    static var shared = SQQuranReader()
    
    var surahs: [SQSurah]! = []
    var mediaPurchased: Bool = false
    
    func surah(with name: String!) -> SQSurah? {
        for surah in self.surahs {
            if surah.name == name {
                return surah
            }
        }; return nil
    }
    
    func surah(at index: Int) -> SQSurah! {
        if index >= surahs.count || index < 0 {
            return nil
        }
        return surahs[index]
    }
    
    fileprivate init() {
        let parser = XMLDictionaryParser.sharedInstance()
        parser?.attributesMode = .unprefixed
        
        let path = Bundle.main.path(forResource: SQQuranReaderConstants.fileName, ofType: "xml")
        let dict = parser?.dictionary(withFile: path!)
        
        for surahDict in dict?[SQQuranReaderConstants.surahsStoreKey] as! [NSDictionary] {
            let newSurahRep = SQSurah(dict: surahDict)
            self.surahs.append(newSurahRep)
        }
    }
}
