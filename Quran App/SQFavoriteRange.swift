//
//  SQFavoriteRange.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/30/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation
import CoreData

class SQFavoriteRange: NSManagedObject {
    
    static let entityName = "SQFavoriteRange"
    
    //MARK: Variables
    var new = false
    
    lazy var ayat: [SQAyah] = {
        let surah = self.surahInfo.surah
        return surah!.ayat.filter {
            return self.indexIsIncluded($0.index)
        }
    }()
    
    class func favoriteRangeWithStartIndex(_ startIndex: Int, endIndex: Int) -> SQFavoriteRange {
        let managedObjectContext = SQAppDelegate.shared.managedObjectContext
        let newObject = NSEntityDescription.insertNewObject(forEntityName: "SQFavoriteRange", into: managedObjectContext) as! SQFavoriteRange
        newObject.startIndex = NSNumber(value: startIndex as Int)
        newObject.endIndex = NSNumber(value: endIndex as Int)
        newObject.new = true
        
        
        return newObject
    }
}

extension SQFavoriteRange {
    override var description: String {
        return "الآيات من \((self.int_startIndex).localized) إلى \((self.int_endIndex + 1).localized)"
    }
    
    var name: String! {
        return "\(surahInfo!.surahName!)"
    }
    
    
    var identifier: String! {
        return "\(surahInfo!.surahName)__\(int_startIndex)__\(int_endIndex)"
    }
    
    //MARK: Working with Ayat
    
    var completedAyatIndexes: [Int] {
        return (surahInfo.completedAyahs as! [Int]).filter {
            return self.indexIsIncluded($0)
        }
    }
    
    
    fileprivate func indexIsIncluded(_ index: Int) -> Bool {
        return index >= self.int_startIndex && index <= self.int_endIndex + 1
    }
    
    func ayahIsCompleted(_ ayah: SQAyah) -> Bool {
        if !ayat.contains(ayah) {
            return false
        }
        
        return completedAyatIndexes.contains(ayah.index)
    }
    
    func complete(ayah: SQAyah){
        if !ayat.contains(ayah) {
            return
        }
        
        surahInfo.add(completeIndex: ayah.index)
    }
    
    func uncomplete(ayah: SQAyah){
        if !ayat.contains(ayah) {
            return
        }
        
        surahInfo.remove(completeIndex: ayah.index)
    }
    
    func completeAll(){
        for ayah in self.ayat {
            surahInfo.add(completeIndex: ayah.index)
        }
    }
    
    func uncompleteAll(){
        for ayah in self.ayat {
            surahInfo.remove(completeIndex: ayah.index)
        }
    }
}

//MARK: Core Data
extension SQFavoriteRange {
    
    @NSManaged var startIndex: NSNumber!
    @NSManaged var endIndex: NSNumber!
    @NSManaged var surahInfo: SQSurahInfo!
    
    var int_startIndex: Int {
        set { self.startIndex  = NSNumber(value: newValue as Int)}
        get { return startIndex!.intValue}
    }
    
    var int_endIndex: Int {
        set { self.endIndex  = NSNumber(value: newValue as Int)}
        get { return endIndex!.intValue}
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        self.int_startIndex = 0
        self.int_endIndex = 0
    }
}
