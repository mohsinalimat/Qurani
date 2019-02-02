//
//  SQProgressItem.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/23/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation

/**
 *  @brief a progress item defines simple function to mark the the class as progressable and show it's progress in the progress views..
 */
protocol SQProgressItem: NSObjectProtocol {
    
    /// the name of item.. required to show it..
    var displayName: String { get }
    
    /**
     A simple function for returing the progress of an object, object must return a value between 0 and 1, the progress will be displayed to the user with the name..
     
     - returns: a Float value between 0 and 1 that represents the progress
     */
    var progress: Float { get }
    
    /** optional message setted once per app launch, gives a human readable string about the progress. default to be nil */
    
    var progressMessage: String { get }

}
