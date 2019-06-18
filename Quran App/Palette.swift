//
//  Palette.swift
//  Flat UI Colors
//
//  Created by Hussein Ryalat on 22.1.2015
//  Copyright (c) 2015 Hussein Ryalat. All rights reserved.
//

import UIKit


public let surahDefaultColor: UIColor = Colors.tint
public let favoritedRangeDefaultColor = Colors.tint

struct Colors {
    
    /* Main Colors*/
    static var title = UIColor.black
    static var contents = UIColor(white: 0.2, alpha: 1.0)
    static var tint = UIColor(hexString: "34A4AA")
    
    /* Secondary Colors */
    static var semiWhite = UIColor(white: 0.93, alpha: 1.0)
    static var lightGray = UIColor(hexString: "#bdc3c7")
    
    /* Extra Colors */
    static var yetAnotherTint = UIColor(red:0.71, green:0.30, blue:0.56, alpha:1.00)
    static var twinkle = UIColor.sunFlower
}

public extension UIColor {
  /**
    Create non-autoreleased color with in the given hex string
    Alpha will be set as 1 by default
    
    - parameter   hexString:
    - returns: color with the given hex string
  */
    convenience init?(hexString: String) {
    self.init(hexString: hexString, alpha: 1.0)
  }

  /**
    Create non-autoreleased color with in the given hex string and alpha
    
    - parameter   hexString:
    - parameter   alpha:
    - returns: color with the given hex string and alpha
  */
    convenience init?(hexString: String, alpha: Float) {
    var hex = hexString

    // Check for hash and remove the hash
    if hex.hasPrefix("#") {
      hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 1))
    }
    
    if (hex.range(of: "(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .regularExpression) != nil) {
    
        // Deal with 3 character Hex strings
        if hex.count == 3 {
          let redHex   = hex.substring(to: hex.index(hex.startIndex, offsetBy: 1))
          let greenHex = hex.substring(with: (hex.index(hex.startIndex, offsetBy: 1) ..< hex.index(hex.startIndex, offsetBy: 2)))
          let blueHex  = hex.substring(from: hex.index(hex.startIndex, offsetBy: 2))
          
          hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
        }

        let redHex = hex.substring(to: hex.index(hex.startIndex, offsetBy: 2))
        let greenHex = hex.substring(with: (hex.index(hex.startIndex, offsetBy: 2) ..< hex.index(hex.startIndex, offsetBy: 4)))
        let blueHex = hex.substring(with: (hex.index(hex.startIndex, offsetBy: 4) ..< hex.index(hex.startIndex, offsetBy: 6)))
        
        var redInt:   CUnsignedInt = 0
        var greenInt: CUnsignedInt = 0
        var blueInt:  CUnsignedInt = 0

        Scanner(string: redHex).scanHexInt32(&redInt)
        Scanner(string: greenHex).scanHexInt32(&greenInt)
        Scanner(string: blueHex).scanHexInt32(&blueInt)

        self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
    }
    else {
        // Note:
        // The swift 1.1 compiler is currently unable to destroy partially initialized classes in all cases,
        // so it disallows formation of a situation where it would have to.  We consider this a bug to be fixed
        // in future releases, not a feature. -- Apple Forum
        self.init()
        return nil
    }
  }

  /**
    Create non-autoreleased color with in the given hex value
    Alpha will be set as 1 by default
    
    - parameter   hex:
    - returns: color with the given hex value
  */
    convenience init?(hex: Int) {
    self.init(hex: hex, alpha: 1.0)
  }
  
  /**
    Create non-autoreleased color with in the given hex value and alpha
    
    - parameter   hex:
    - parameter   alpha:
    - returns: color with the given hex value and alpha
  */
    convenience init?(hex: Int, alpha: Float) {
    let hexString = NSString(format: "%2X", hex)
    self.init(hexString: hexString as String , alpha: alpha)
  }
}

extension UIColor {

    
    class func hexStringFromColor(_ color: UIColor) -> String {
        let components = color.cgColor.components
        
        let r = Float((components?[0])!)
        let g = Float((components?[1])!)
        let b = Float((components?[2])!)
        
        return NSString(format: "#%02lX%02lX%02lX", lroundf(r) / 255, lroundf(g) / 255, lroundf(b) / 255) as String
    }
    

    // green sea
    static var turquoise:UIColor { return UIColor(hexString: "#1abc9c")! }
    static var greenSea: UIColor { return UIColor(hexString: "#16a085")! }
    
    // green
    static var emerald: UIColor { return UIColor(hexString: "#2ecc71")! }
    static var nephritis:UIColor { return UIColor(hexString: "#27ae60")! }
    
    // blue
    static var peterRiver: UIColor { return UIColor(hexString: "#3498db")! }
    static var belizeHole: UIColor { return UIColor(hexString: "#2980b9")! }
    
    // purple
    static var amethyst: UIColor { return UIColor(hexString: "#9b59b6")! }
    static var wisteria: UIColor { return UIColor(hexString: "#8e44ad")! }
    
    // dark blue
    static var wetAsphalt: UIColor { return UIColor(hexString: "#34495e")! }
    static var midnightBlue: UIColor { return UIColor(hexString: "#2c3e50")! }
    
    // yellow
    static var sunFlower: UIColor { return UIColor(hexString: "#f1c40f")! }
    static var flatOrange: UIColor { return UIColor(hexString: "#f39c12")! }
    
    // orange
    static var carrot: UIColor { return UIColor(hexString: "#e67e22")! }
    static var pumkin: UIColor { return UIColor(hexString: "#d35400")! }
    
    // red
    static var alizarin: UIColor { return UIColor(hexString: "#e74c3c")! }
    static var pomegranate: UIColor { return UIColor(hexString: "#c0392b")! }
    
    // white
    static var clouds: UIColor { return UIColor(hexString: "#ecf0f1")! }
    static var silver: UIColor { return UIColor(hexString: "#bdc3c7")! }
    
    // gray
    static var asbestos: UIColor { return UIColor(hexString: "#7f8c8d")! }
    static var concerte: UIColor { return UIColor(hexString: "#95a5a6")! }
    
    //custom gray
    static var sk_lightGray: UIColor { return UIColor(white: 0.6, alpha: 1.0) }
    static var sk_gray: UIColor { return UIColor(white: 0.5, alpha: 1.0) }
    static var sk_darkGray: UIColor { return UIColor(white: 0.3, alpha: 1.0) }
}
