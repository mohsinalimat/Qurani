//
//  SQPickingResult.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


class SQPickingResult: NSObject {
    var surahIndex: Int
    var beginAyahIndex: Int
    var endAyahIndex: Int
    
    init(surahIndex: Int, beginAyahIndex: Int, endAyahIndex: Int) {
        self.surahIndex = surahIndex
        self.beginAyahIndex = beginAyahIndex
        self.endAyahIndex = endAyahIndex
    }
}
