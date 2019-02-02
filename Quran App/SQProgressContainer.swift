//
//  SQProgressContainer.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/2/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


protocol SQProgressContainer: SQProgressItem {
        
    /* an array of items to display */
    var progressItems: [SQProgressItem] { get }
}

