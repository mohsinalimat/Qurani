//
//  SQSurahInfo.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation
import CoreData

class SQSurahInfo: NSManagedObject {
    
    static let entityName = "SQSurahInfo"
    
    lazy var surah: SQSurah! = {
       SQQuranReader.shared.surah(with: self.surahName)!
    }()
    
    var ayat: [SQAyah] {
        return surah.ayat
    }
    
    @NSManaged var surahName: String!
    @NSManaged var surahIndex: NSNumber!
    
    @NSManaged var completedAyahs: NSArray!
    @NSManaged var favoritedRanges: NSOrderedSet!
    
    var hasNewFavoritedRanges: Bool = false
    var currentFavoriteRange: SQFavoriteRange?
    
    var isNew: Bool = false
    var cachedMessage: String? = nil
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.surahName = ""
        self.surahIndex = NSNumber(value: 0 as Int)
        
        self.completedAyahs = NSArray()
        self.favoritedRanges = NSOrderedSet()
        
        self.isNew = true
    }
}

//MARK: Working with favorite ranges
extension SQSurahInfo {
    func add(favoriteRange: SQFavoriteRange){
        favoriteRange.surahInfo = self
        hasNewFavoritedRanges = true
        var array = favoritedRanges.array as! [SQFavoriteRange]
        array.append(favoriteRange)
        self.favoritedRanges = NSOrderedSet(array: array)
        SQQuranStateManager.shared.save()
    }
    
    func remove(favoriteRange: SQFavoriteRange){
        if SQQuranStateManager.shared.currentFavoriteRange == favoriteRange {
            SQQuranStateManager.shared.currentFavoriteRange = nil
        }
        
        let orderedMutableSet = (favoritedRanges.mutableCopy() as! NSMutableOrderedSet)
        orderedMutableSet.remove(favoriteRange)
        self.favoritedRanges = orderedMutableSet
        
        favoriteRange.surahInfo = nil
        self.favoritedRanges = orderedMutableSet
        SQAppDelegate.shared.managedObjectContext.delete(favoriteRange)
        SQQuranStateManager.shared.save()
    }
    
    
}

//MARK: Working With Ayat
extension SQSurahInfo {
    func add(completeIndex: Int){
        if !self.completedAyahs.contains(completeIndex) {
            let mutableCopy = self.completedAyahs.mutableCopy() as! NSMutableArray
            mutableCopy.add(completeIndex)
            
            self.completedAyahs = mutableCopy
            SQQuranStateManager.shared.save()
            cachedMessage = nil
        }
    }
    
    func remove(completeIndex: Int){
        if self.completedAyahs.contains(completeIndex) {
            let indexInArray = completedAyahs.index(of: completeIndex)
            if indexInArray != NSNotFound {
                let mutableCopy = completedAyahs.mutableCopy() as! NSMutableArray
                mutableCopy.remove(completeIndex)
                
                completedAyahs = mutableCopy
                SQQuranStateManager.shared.save()
                cachedMessage = nil
            }
        }
    }
    
    func ayahIsCompleted(_ ayah: SQAyah) -> Bool {
        if ayah.surah != self.surah {
            return false
        }
        
        return self.completedAyahs.contains(ayah.index)
    }
}
