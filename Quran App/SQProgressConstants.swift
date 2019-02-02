//
//  SQProgressConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/2/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


let fM1 = "أحسنت!! لقد حفظت السورة كاملة!"
let fM2 = "أنت رائع 😍 حفظت السورة كاملة!! "
let fM3 = "طقع 😝! لقد حفظت السورة ❤️"
let fM4 = "وفقك الله يا صديقي ☺️✌️ .. لقد أتممت السورة !"

extension EmptyState {
    static let chartsTitle = "الإحصائات "
    static let chartsDetails = "يمكنك متابعة تقدمك في الحفظ في السور والمحددات من هنا 🙌"
    
}

struct Progress {
    static let empty: [String] = []
    static let full: [String] = [fM1, fM2, fM3, fM4]
    
    static func message(completed: Int, total: Int) -> String {
        /* check the type of the message we want to deliver.. */
        if completed == total {
            return Progress.full.random
        }
        
        /* generate a message.. */
        let beginningString = "لقد حفظت "
        
        let nextString = Names.Ayah.name(for: completed)
        let nextString2 = " من أصل "
        let finalString = Names.Ayah.name(for: total)
        
        return beginningString + nextString + nextString2 + finalString
    }
    
    static func shortedMessage(completed: Int, total: Int) -> String {
        /* check the type of the message we want to deliver.. */
        if completed == 0 {
            /* no progress, return an empty state title.. ( random ) */
            return "لم تحفظ شيئاً منها بعد 😢"
        } else if completed == total {
            return "أتممت المحددة كاملة 😍"
        }
        
        /* generate a message.. */
        let beginningString = "أتممت "
        
        let nextString = Names.Ayah.name(for: completed)
        return beginningString + nextString + "."
        
    }
}
