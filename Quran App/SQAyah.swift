//
//  SQAyah.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation

class SQAyah: NSObject, NSCoding, Comparable {
    
    let kTextKey = "text"
    let kIndexKey = "index"
    
    var text: String!
    var index: Int!
    
    weak var soundItem: SQSoundItem?
    
    class func id(for ayahIndex: Int, inSurah surahIndex: Int) -> String {
        var finalString = ""
        
        let sAyahIndex = "\(ayahIndex)"
        let sSurahIndex = "\(surahIndex)"
        
        
        let howManyZerosForSurahIndex = 3 - sSurahIndex.length
        for _ in 0..<howManyZerosForSurahIndex {
            finalString.append("0")
        }
        
        finalString.append(sSurahIndex)
        
        let howManyZerosForAyahIndex = 3 - sAyahIndex.length
        for _ in 0..<howManyZerosForAyahIndex {
            finalString.append("0")
        }
        
        finalString.append(sAyahIndex)
        
        return finalString
    }
    
    var id: String {
        return SQAyah.id(for: self.index!, inSurah: surah.index!)
    }
    
    var url: URL? {
        if let bundleURL =  Bundle.main.url(forResource: id, withExtension: "mp3"){
            return bundleURL
        }
        
        return ayahUrl(for: self)
    }

    weak var surah: SQSurah!

    var realIndex: Int {
        return index - 1
    }
    
    
    override var description: String {
        return "\(index): { \(text) }"
    }
    
    
    required init(dict: NSDictionary) {
        self.text = dict[kTextKey] as? String
        self.index = Int(dict[kIndexKey] as! String)!
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.text = aDecoder.decodeObject(forKey: kTextKey) as? String
        self.index = aDecoder.decodeInteger(forKey: kIndexKey)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: kTextKey)
        aCoder.encode(self.index, forKey: kIndexKey)
    }
}


extension SQAyah: SQDictionaryRep {
    func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict[kTextKey] = text
        dict[kIndexKey] = "\(String(describing: index))"
        
        return dict
    }
}

extension SQAyah {
    public static func <(lhs: SQAyah, rhs: SQAyah) -> Bool {
        if lhs.surah.name != rhs.surah.name {
            return false
        }
        
        return lhs.index < rhs.index
    }
    
    public static func <=(lhs: SQAyah, rhs: SQAyah) -> Bool {
        if lhs.surah.name != rhs.surah.name {
            return false
        }
        
        return lhs.index <= rhs.index
    }

    public static func >=(lhs: SQAyah, rhs: SQAyah) -> Bool {
        if lhs.surah.name != rhs.surah.name {
            return false
        }
        
        return lhs.index >= rhs.index
    }
    
    public static func >(lhs: SQAyah, rhs: SQAyah) -> Bool {
        if lhs.surah.name != rhs.surah.name {
            return false
        }
        
        return lhs.index > rhs.index
    }
}
