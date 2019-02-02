//
//  Constants.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/22/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor


/* For font sizes: 
 
 - 17 ( Contents iPhone ), 21 ( Contents iPad )
 - 21 ( Subtitle iPhone ), 28 ( Subtitle iPad )
 - 32 ( Title iPhone ), 50 ( Title iPad )
 
 */


public let kDeveloperEmail = "hus.sc@aol.com"
public let kEmailSubjet = "قرآني - تواصل"
public let kAppLink = "https://itunes.apple.com/jo/app/alqran-almhfwz/id1118739112?mt=8"
public let kProductIdentifier = "com.mesklab.mahfooth.Full"

enum Icons {
    case settings
    case about
    case store
    
    /* main media controls */
    case next
    case previous
    case play
    case pause
    
    /* extra media controls ( Player )*/
    case `repeat`
    case restart
    
    case rate1
    case rate2
    case rate3
    
    /* Extra:D */
    case complete
    case close
}

extension Icons {
    
    var fileName: String {
        switch self {
        case .settings: return "gear"
        case .about: return "heart"
        case .store: return "cart"
            
            
            /* main media controls */
        case .next: return "forward"
        case .previous: return "rewind"
        case .play: return "play"
        case .pause: return "pause"
            
            /* extra media controls ( Player )*/
        case .`repeat`: return "retweet"
        case .restart: return "clockwise"
            
        case .rate1: return "rate1"
        case .rate2: return "rate2"
        case .rate3: return "rate3"
            
            /* Extra:D */
        case .complete: return "checkmark"
        case .close: return "close"
            
        }
    }
    
    var image: UIImage {
        switch self {
        case .settings: return UIImage(named: "gear")!
        case .about: return UIImage(named: "heart")!
        case .store: return UIImage(named: "cart")!
            
            
            /* main media controls */
        case .next: return UIImage(named: "forward")!
        case .previous: return UIImage(named: "rewind")!
        case .play: return UIImage(named: "play")!
        case .pause: return UIImage(named: "pause")!
            
            /* extra media controls ( Player )*/
        case .`repeat`: return UIImage(named: "retweet")!
        case .restart: return UIImage(named: "clockwise")!
            
        case .rate1: return UIImage(named: "rate1")!
        case .rate2: return UIImage(named: "rate2")!
        case .rate3: return UIImage(named: "rate3")!
            
            /* Extra:D */
        case .complete: return UIImage(named: "checkmark")!
        case .close: return UIImage(named: "close")!
            
        }
    }
}


enum SettingsKeys {
    static let DidBuyPack = "Did Buy Full"
    static let DidFinishTransfaring = "YOU ARE SOOOO LUCKY!"
    static let DidPauseDownload = "DidPause Download.."
    static let DidRestorePurchase = "Did restore.."
    static let FirstOpen = "ISFIRSTOPEN"
}


