//
//  SQModelManager.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import CoreData

let kAvailableIndexes: [Int] = []

class SQQuranStateManager: NSObject {
    
    static var shared: SQQuranStateManager = SQQuranStateManager()

    fileprivate(set) lazy var surahInfos: [SQSurahInfo] = {
        let managedObjectContext = SQAppDelegate.shared.managedObjectContext
        let entityName = SQSurahInfo.entityName
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "surahIndex", ascending: true)]
        
        var objects: [SQSurahInfo]? = []
        do {
            objects = try managedObjectContext.fetch(fetchRequest) as? [SQSurahInfo]
        } catch {
            print("ERROR WHILE FETCHING OBJECTS.. \(#file): \(#line)")
        }
        
        return objects ?? []
    }()
    
    
    var currentSurahInfo: SQSurahInfo?
    var currentFavoriteRange: SQFavoriteRange?
    
    var hasInsertedSurahInfo = false
    var hasDeletedSurahInfo = false
    var deletedSurahInfoIndex = -1
    
    //MARK: Initialization and Singltone
    
    override init() { }
    
    
    //MARK: Surahs
    
    func surahInfo(for surah: SQSurah, shouldGenerate generateIfNeeded: Bool = false) -> SQSurahInfo? {
        for surahInfo in self.surahInfos {
            if surahInfo.surahName == surah.name {
                return surahInfo
            }
        }
        
        // no surah info currently attached for that surah rep..
        if generateIfNeeded {
            
            // create it..
            let managedObjectContext = SQAppDelegate.shared.managedObjectContext
            let newSurahInfo = NSEntityDescription.insertNewObject(forEntityName: SQSurahInfo.entityName, into: managedObjectContext) as! SQSurahInfo
            
            
            // customize it..
            newSurahInfo.surahName = surah.name
            newSurahInfo.surahIndex = surah.index as NSNumber
            
            
            // add it..
            self.surahInfos.append(newSurahInfo)
            
            hasInsertedSurahInfo = true

            save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.didInsertSurahInfo), object: self, userInfo: [Keys.surahInfo: newSurahInfo])
            
            return newSurahInfo
        }
        
        return nil
    }

    func remove(surahInfo: SQSurahInfo){
        let index = surahInfos.index(of: surahInfo)!
        
        if currentFavoriteRange?.surahInfo == surahInfo {
            currentFavoriteRange = nil
        }
        
        for fr in surahInfo.favoritedRanges.array {
            surahInfo.remove(favoriteRange: fr as! SQFavoriteRange)
        }
        
        
        if self.currentSurahInfo == surahInfo {
            currentSurahInfo = nil
        }
        
        
        surahInfos.remove(at: index)
        let managedObjectContext = SQAppDelegate.shared.managedObjectContext
        managedObjectContext.delete(surahInfo)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NSNotification.Name.didRemoveSurahInfo), object: self, userInfo: [Keys.index: index])
        save()
        
        hasDeletedSurahInfo = true
        deletedSurahInfoIndex = index
    }
    
    //MARK: General Functions

    func save(){
        SQAppDelegate.shared.saveContext()
    }
}

