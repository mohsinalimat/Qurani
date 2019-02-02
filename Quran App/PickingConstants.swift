//
//  PickingConstants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation


struct PickingConstants {
    struct SurahPicker {
        static let Title = " إختيار السورة"
        static let Subtitle = "إختر السورة التي تريد الحفظ منها"
    }
    
    struct BeginIndexPicker {
        static let Title = "بداية الحفظ"
        static let Subtitle = "من أي آية تريد أن تبدأ حفظك ؟"
        
    }
    
    struct EndIndexPicker {
        static let Title = "نهاية الحفظ"
        static let Subtitle = "إلى أي آية تريد أن تحفظ ؟"
    }
    
    struct Completion {
        
    }
}

enum SQPickingStep: Int {
    case selectingSurah = 0,
    
    selectingBeginAyah = 1,
    
    selectingEndAyah = 2,
    
    completing = 3, // finished selecting the info's, now reviewing them.
    
    undefined = 4
}

