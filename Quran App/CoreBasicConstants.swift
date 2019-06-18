//
//  CoreBasicConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

struct SQQuranReaderConstants {
    public static let fileName = QuranTextSource.simpleEnhanced.name
    public static let surahsStoreKey = "sura"
}

enum QuranTextSource: String {
    case simple
    case uthmani
    case simpleEnhanced
    
    private var prefix: String {
        return "quran-"
    }
    
    var name: String {
        switch self {
        case .simpleEnhanced:
            return prefix + "simple-enhanced"
        default:
            return prefix + rawValue
        }
    }
}
