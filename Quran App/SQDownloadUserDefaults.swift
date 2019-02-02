//
//  SQDownloadUserDefaults.swift
//  Quran App
//
//  Created by Hussein Ryalat on 2/2/18.
//  Copyright © 2018 Sketch Studio. All rights reserved.
//

import Foundation

class SQDownloadUserDefaultsManager {
    
    enum SurahDownloadFlag: Int {
        case manualCheck = 2
        
        fileprivate static func from(rawValues: [Int]) -> [SurahDownloadFlag] {
            return rawValues.map { SurahDownloadFlag(rawValue: $0)! }
        }
        
        fileprivate static func rawValues(from flags: [SurahDownloadFlag]) -> [Int] {
            return flags.map { $0.rawValue }
        }
    }
    
    static var shared = SQDownloadUserDefaultsManager()
    
    private(set) var userDefaults: UserDefaults = UserDefaults.standard
    
    func set(flags: [SurahDownloadFlag], for key: String){
        userDefaults.set(SurahDownloadFlag.rawValues(from: flags), forKey: key)
    }
    
    func flags(for key: String) -> [SurahDownloadFlag]{
        if let rawValues = userDefaults.array(forKey: key) as? [Int] {
            return SurahDownloadFlag.from(rawValues: rawValues)
        }
        
        return []
    }
}
