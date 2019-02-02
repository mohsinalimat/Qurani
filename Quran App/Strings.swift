//
//  Strings.swift
//  Quran App
//
//  Created by Hussein Ryalat on 11/18/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import Foundation

struct ErrorMessages {
    static let audioOpen = "خطأ أثناء تشغيل الصوت!"
    static let mailOpen = "حدث خطأ أثناء فتح البريد.. تأكد أن بريدك موجود في الجهاز :)"
    static let invaildStartIndexSelection = "لا يمكن اختيار آخر آية في السورة لتكون آية البداية!"
    static let invaildEndIndexSelection = "لا يمكن أن تكون آية النهاية قبل ’آية البداية!"
    static let cantAccessStore = "حدث خطأ أثناء عملية الوصول إلى المتجر، حاول لاحقا.."
}

struct EmptyState {
    static let favoritesTitle  = "مرحباً بك 🙂"
    static let favoritesDetails = "لماذا لا تبدأ بتجربة إضافة محددة جديدة لتبدأ الحفظ؟"
}


struct Messages {
    struct StoreStuff {
        static let success = "تمت عملية الشراء بنجاح، شكراً لك :)"
    }
    
    static let mailSent = "شكرا لك :) سنحاول الرد بأقرب وقت ممكن.."
    
}

struct Labels {
    
    struct Tips {
        static let `repeat` = "إعادة الآية نفسها عند الانتهاء"
        static let restart = "إعادة تشغيل الآية من البداية"
        static let rate = "تغيير سرعة صوت المقرئ"
    }
    
    let welcomingMessage = "احفظ القرآن عبر تقسيم السور إلى أجزاء صغيرة لتسهيل حفظها  ^^"
    
    /* TabBar controller */
    static let settings = "الإعدادات 👷"
    static let aboutTheApp = "عن التطبيق ❤️"
    static let restorePurchases = "استعادة المشتريات 💰"
    
    /* In the mini player..*/
    static let popupSubtitle = "اسحب للأعلى لرؤية المزيد"
    
    /* Favorites Screen */
    static let deleteFRConfirmationTitle = "حذف المحددة "
    static let deleteFRConfirmationMessage = "سيتم حذف المحددة وستخسر تقدمك فيها 😱"
    
    static let deleteSIConfirmationTitle = "حذف السورة كاملة 😱😱"
    static let deleteSIConfirmationMessage = "سيتم حذف السورة كاملة وما تحتويه من محددات.. وستخسر تقدمك فيها!"
    
    static let frOptionsTitle = "المحددة"
    static let frOptionsMessage = "المحددة هي جزء من السورة لتسهيل الحفظ 🙏"
    
    /* Store Stuff.. */
    static let yes = "اذهب إلى المتجر"
    static let noThanks = "لا شكراً"
    
    static let sure = "نعم أنا متأكد"
    static let IveChangedMyMind = "لا غيرت رأيي"
    
    static let unlockAlertTitle = "السورة مقفلة 🔒"
    static let unlockAlertDescription = "السورة ليست من ضمن السور المجانية، لتجربتها والاستمتاع بكامل السور، فضلاً قم بشراء النسخة الكاملة"
    static let restore = "اشتريت مسبقاً؟ استعادة المشتريات"
    
    struct Buttons {
        static let ok = "حسنا"
        static let no = "إلغاء"
        static let later = "لاحقا!"
        static let remove = "إزالة"
        
        static let share = "🎉 مشاركة المحددة! "
        static let delete = "😱 حذف المحددة "
        static let cancel = "إلغاء"
    }
}
