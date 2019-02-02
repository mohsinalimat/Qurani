//
//  SQArrayTransformer.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

class SQArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        return NSKeyedArchiver.archivedData(withRootObject: value as! NSArray)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with: value as! Data)
    }
}
