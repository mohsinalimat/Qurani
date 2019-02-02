//
//  SQProgressItemsManager.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/2/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

/* represents a glue between the quran memorization state group and charts group. */

extension SQFavoriteRange: SQProgressItem {
    var displayName: String {
        return self.description
    }
    
    var progress: Float {
        return Float(self.completedAyatIndexes.count) / Float(self.ayat.count)
    }
    
    var progressMessage: String {
        return Progress.shortedMessage(completed: self.completedAyatIndexes.count, total: self.ayat.count)
    }
}

extension SQSurahInfo: SQProgressContainer {
    var displayName: String {
        return self.surahName
    }
    
    var progressMessage: String {
        /* if there is a cached message, get it :D */
        if cachedMessage == nil {
            cachedMessage = Progress.message(completed: self.completedAyahs.count, total: self.ayat.count)
        }

        return cachedMessage!
    }
    
    var progressItems: [SQProgressItem] {
        return self.favoritedRanges.array as! [SQProgressItem]
    }
    
    var progress: Float {
        return Float(self.completedAyahs.count) / Float(self.ayat.count)
    }
}

class SQProgressItemsManager {
    
    static var shared = SQProgressItemsManager()
    
    var progressContainers: [SQProgressContainer] {
        return SQQuranStateManager.shared.surahInfos.filter {
            return $0.progress > 0
        }
    }
}





