//
//  SQQuranStatbleConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/2/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


public let kAmmaSurahsGroupName = "جزء عم"
public let kTabarakSurahsGroupName = "جزء تبارك"

public let kAmmaSurahsGroupRange = NSMakeRange(78, 36)
public let kTabarakaSurahsGroupRange = NSMakeRange(67, 11)


extension NSNotification.Name {
    static let didRemoveSurahInfo = "SurahInfoRemove"
    static let didInsertSurahInfo = "SurahInfoInsert"
}

struct Keys {
    static let surahInfo = "SurahInfo"
    static let favoriteRange = "FavoriteRange"
    static let index = "index"
}

struct Sharing {
    static let footerText = "عبر تطبيق القرآن المحفوظ:\n\(kAppLink)"
    
    static func shareMessage(completed: Int, total: Int, surahName: String) -> String {
        /* three states, no progress, or in progress, or completed.. */
        
        /* 1: An Empty progress share message */
        if completed == 0 {
            return "لقد بدأت بحفظ \(Names.Surah.one) \(surahName)!!" + "\n" + footerText
        }
            /* 2: A completed progress share message */
        else if completed == total {
            return "لقد حفظت \(Names.Surah.one) \(surahName) كاملة!!" + "\n" + footerText
        }
        
        /* 3: An in progress share message */
        let ayah = Names.Ayah.name(for: completed)
        return "لقد حفظت \(" ")\(ayah) من \(Names.Surah.one) \(surahName)!" + "\n" + footerText
    }
    
    static func shareMessage(favoriteRange: SQFavoriteRange) -> String {
        let line1 = "أنا الآن أحفظ ب\(Names.Surah.one) \(favoriteRange.surahInfo!.surahName!).."
        let line2 = favoriteRange.description
        return line1 + "\n" + line2 + "\n" + footerText
    }
}

struct Names {
    
    struct Surah {
        static let one = "سورة"
        static let two = "سورتان"
        static let plural = "سور"
        
        static func name(for number: Int) -> String {
            return Names.name(for: number, oneName: one, twoName: two, pluralName: plural)
        }
    }
    
    struct Ayah {
        static let one = "آية"
        static let two = "آيتان"
        static let plural = "آيات"
        
        static func name(for number: Int) -> String {
            return Names.name(for: number, oneName: one, twoName: two, pluralName: plural)
        }
    }
    
    struct FavoriteRange {
        static let one = "محددة"
        static let two = "محددتان"
        static let plural = "محددات"
        
        static func name(for number: Int) -> String {
            return Names.name(for: number, oneName: one, twoName: two, pluralName: plural)
        }
    }
    
    static func name(for number: Int, oneName: String, twoName: String, pluralName: String) -> String {
        var name = ""
        var shouldIncludeCompletedNumber = true
        let oneSuffixString = " واحدة"
        
        let magicNumber = number / 100
        if magicNumber > 10 {
            let numberToUse = number - (magicNumber * 100)
            if numberToUse < 3 {
                name = oneName
            } else {
                name = ( numberToUse <= 10 ) ? pluralName : oneName
            }
            
            return "\(number.localized) \(name)"
        }
        
        /* ( more than 9 ) ( 2 ) ( 3 to 9 ) */
        if number < 3 {
            name = number == 2 ? twoName : oneName + oneSuffixString
            shouldIncludeCompletedNumber = false
        } else  {
            name = ( number <= 10 ) ? pluralName : oneName
        }
        
        return shouldIncludeCompletedNumber ? "\(number.localized) \(name)" : name
    }
}
