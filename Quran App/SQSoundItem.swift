//
//  SQSoundItem.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


class SQSoundItem: NSObject {
    
    var url: URL
    var ayah: SQAyah
    
    init(url: URL, ayah: SQAyah){
        self.url = url
        self.ayah = ayah
        
        super.init()
        self.ayah.soundItem = self
    }
}
