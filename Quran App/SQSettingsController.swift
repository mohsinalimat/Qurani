//
//  SQSettingsController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/24/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

enum FontSizeType: Int {
    case bigger = 0,
    regular = 1,
    smaller = 2
    
    func title() -> String {
        switch self.rawValue {
        case 0:
            return "أصغر"
        case 1:
            return "عادي"
        case 2:
            return "أكبر"
        default:
            return "UNKNOWN TYPE"
        }
    }
    
    func fontSize_phone() -> CGFloat {
        switch self {
        case .bigger:
            return 26
        case .regular:
            return 21
        case .smaller:
            return 17

        }
    }
    
    func fontSize_pad() -> CGFloat {
        switch self {
        case .bigger:
            return 32
        case .regular:
            return 28
        case .smaller:
            return 21
        }
    }
    
    static func allTypes() -> [FontSizeType] {
        return [FontSizeType.smaller, FontSizeType.regular, FontSizeType.bigger]
    }
    
    static let name = " حجم الخط ✍️"
}


// User Editable Settings..
extension SettingsKeys {
    
    /* controllering the font size of ayat .. not including the titles and labels ..*/
    static let FontSize = "FontSize"
    
    /* should auto mark ayat as completed after listening to them .. */
    static let AutoComplete = "AutoComplete"
    
    /* repeat the favorite range playing once you finish playing it ..? */
    static let RepeatOnFinish = "RepeatOnFinish"
    
    /// ****Deprecated*****
    /* wether to show surahs progresses or keep them as favorite ranges .. */
    static let ProgressType = "ProgressType"
}

class SQSettingsController: NSObject {
    class func fontSize() -> CGFloat {
        let fontTypeRaw = UserDefaults.standard.integer(forKey: SettingsKeys.FontSize)
        let fontType = FontSizeType(rawValue: fontTypeRaw)!

        return UIDevice.current.userInterfaceIdiom == .phone ? fontType.fontSize_phone() : fontType.fontSize_pad()
    }
    
    
    class func shouldAutoComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: SettingsKeys.AutoComplete)
    }
    
    class func shouldRepeatQueueOnFinish() -> Bool {
        return UserDefaults.standard.bool(forKey: SettingsKeys.RepeatOnFinish)
    }
}
