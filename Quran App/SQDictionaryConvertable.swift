//
//  SQDictionaryConvertable.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/21/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation

/**
 *  @brief Any object conforms to this protocol implements one initializer and one function, both used to import/export the object in dictionary parameter..
 */
protocol SQDictionaryRep: NSObjectProtocol {
    
    /**
     Initializes an object with a dictionary of values and keys pairs, senders expect the reciever to set the values of this dictionary to any found keys in the reciever
     
     - parameter dict: the dict that contains values and keys to set
     
     - returns: returns a new instance of the object.
     */
    init(dict: NSDictionary)
    
    /**
     Archives and encapsulates the reciever into dictionary of values and keys in the object
     
     - returns: a dictoinary of values and keys of the reciever
     */
    func toDictionary() -> NSDictionary
}