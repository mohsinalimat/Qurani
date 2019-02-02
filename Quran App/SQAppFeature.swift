//
//  SQAppFeature.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/5/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

class SQAppFeature {
    var text: String
    var image: UIImage?
    
    init(text: String, image: UIImage?) {
        self.text = text
        self.image = image
    }
    
    class func features() -> [SQAppFeature]{
        let charts = SQAppFeature(text: "الإحصائات، لمشاهدة تقدمك في حفظ كتاب الله 😉", image: UIImage(named: "pie_chart_large")?.imageWithSize(CGSize(width: 100,height: 100)))
        let bugFixes = SQAppFeature(text: "إصلاح الأخطاء، وتحسين الأداء 🙌", image: UIImage(named: "bug_fixes_large")?.imageWithSize(CGSize(width: 100,height: 100)))
        let designImprovments = SQAppFeature(text: "إعادة التصميم، وجعل التطبيق أبسط✨", image: UIImage(named: "design_large")?.imageWithSize(CGSize(width: 100,height: 100)))
        
        let features: [SQAppFeature] = [charts, bugFixes, designImprovments]
        
        return features
    }
}



