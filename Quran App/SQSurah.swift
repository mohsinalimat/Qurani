//
//  SQSurahRep.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation

class SQSurah: NSObject {
    
    class func id(for index: Int) -> String {
        var finalString = ""
        let string = "\(index)"
        
        let howManyZeros = 3 - string.length
        for _ in 0..<howManyZeros {
            finalString.append("0")
        }
        finalString.append(string)
        
        return finalString
    }
    
    var id: String {
        return SQSurah.id(for: index)
    }
    
    let kNameKey = "name"
    let kIndexKey = "index"
    let kAyatKey = "aya"
    
    var name: String!
    var index: Int!
    
    var ayat: [SQAyah]!
    
    var realIndex: Int {
        return index - 1
    }
    
    var isFirstSurah: Bool {
        return self.index == 1
    }
    
    var isLastSurah: Bool {
        return self.index == 114
    }
    
    override var description: String {
        return "وعدد آياتها \(self.ayat.count.localized)"
    }
    
    required init(dict: NSDictionary) {
        self.name = dict[kNameKey] as! String
        self.index = Int(dict[kIndexKey] as! String)!
        
        super.init()
        
        var ayat: [SQAyah] = []
        for ayaDict in dict[kAyatKey] as! [NSDictionary] {
            let aya = SQAyah(dict: ayaDict)
            aya.surah = self
            ayat.append(aya)
        }
        
        self.ayat = ayat
}
    }


extension SQSurah: SQDictionaryRep {
    func toDictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary[kNameKey] = name
        dictionary[kIndexKey] = "\(index)"
        
        let ayatArray = NSMutableArray()
        for ayaRep in ayat {
            ayatArray.add(ayaRep.toDictionary())
        }
        
        dictionary[kAyatKey] = ayatArray
        return dictionary
    }
}
