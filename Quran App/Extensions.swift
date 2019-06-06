//
//  Extensions.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/19/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import Foundation
import UIKit
import Whisper

extension UIImage {
    func imageWithSize(_ targetSize: CGSize) -> UIImage? {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}

extension Array where Element: Comparable {
    func binarySearch(key: Element) -> Int? {
        var lowerBound = 0
        var upperBound = self.count
        while lowerBound < upperBound {
            let midIndex = lowerBound + (upperBound - lowerBound) / 2
            if self[midIndex] == key {
                return midIndex
            } else if self[midIndex] < key {
                lowerBound = midIndex + 1
            } else {
                upperBound = midIndex
            }
        }
        return nil
    }
}

extension UIView: CAAnimationDelegate {
    func animateBorder(color: UIColor, reverse: Bool){
        let shapeLayer = CAShapeLayer()
        
        /* customize the shape based on the view properties.. */
        shapeLayer.lineWidth = borderWidth * 5
        shapeLayer.strokeColor = color.cgColor //UIColor.black.cgColor
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        /* start from zero and animate it to one.. */
        shapeLayer.strokeEnd = reverse ? 1 : 0
        shapeLayer.name = "borderLayer"
        shapeLayer.masksToBounds = false
        shapeLayer.zPosition = 1000
        
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.toValue = NSNumber(value: reverse ? 0 : 1)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        
        
        layer.addSublayer(shapeLayer)
        shapeLayer.add(animation, forKey: "border")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        for subLayer in self.layer.sublayers! {
            if subLayer.name == "borderLayer" {
                let shapeLayer = subLayer as! CAShapeLayer
                self.layer.borderColor = shapeLayer.strokeColor
                subLayer.removeFromSuperlayer()
            }
        }
    }
}

extension String {
    var length: Int {
        return characters.count
    }
}

class SQLocalizer: NSObject {
    static let shared: SQLocalizer! = SQLocalizer()
    
    var numberFormatter: NumberFormatter
    
    override init() {
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.locale = Locale(identifier: "ar")
    }
    
    func localize(number: NSNumber) -> String {
        return numberFormatter.string(from: number)!
    }
}

extension Int {
    var localized: String {
        return SQLocalizer.shared.localize(number: NSNumber(value: self))
    }
}


public extension NSObject {
    
    class var className: String {
        
        /* Swift split is INSANELY slow */
        let classString = NSStringFromClass(self) as NSString
        let comps = classString.components(separatedBy: ".")
        
        if let last = comps.last {
            return last
        }
        
        return classString as String
    }
}

extension UIViewController {
    
    func showMessage(_ message: String, color: UIColor = UIColor.globalTint, action: (() -> Void)? = nil){
        let murmur = Murmur(title: message, backgroundColor: color, titleColor: UIColor.white, action: action)
        
        Whisper.show(whistle: murmur, action: .show(3))
    }
    
    func showErrorMessage(_ message: String, action: (() -> Void)? = nil){
        showMessage(message, color: UIColor.alizarin, action: action)
    }
    
    class func createFromStoryboard(_ storyboard: UIStoryboard) -> Self? {
        return createFromStoryboard(self, storyboard: storyboard)
    }
    
    fileprivate class func createFromStoryboard<T>(_ type: T.Type, storyboard: UIStoryboard) -> T? {
        return storyboard.instantiateViewController(withIdentifier: className) as? T
    }
    
    fileprivate class func createFromMainStoryboard<T>(_ type: T.Type, identifier: String) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
    
    
    
    @IBAction func popNavigationController() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    class func createFromMainStoryboardWithIdentifier(_ identifier: String) -> Self? {
        return createFromMainStoryboard(self, identifier: identifier)
    }
    
    fileprivate class func create<T>(fromStoryboardWithName storyboardName: String, identifier: String) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
    
    class func create(from storyboardName: String, withIdentifier identifier: String) -> Self? {
        return create(fromStoryboardWithName: storyboardName, identifier: identifier)
    }
    
    func share(_ text: String){
        let objectsToShare = [text]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        let excludeActivities = [UIActivity.ActivityType.airDrop,
                                 UIActivity.ActivityType.print,
                                 UIActivity.ActivityType.assignToContact,
                                 UIActivity.ActivityType.saveToCameraRoll,
                                 UIActivity.ActivityType.addToReadingList,
                                 UIActivity.ActivityType.postToFlickr,
                                 UIActivity.ActivityType.postToVimeo]
        activityVC.excludedActivityTypes = excludeActivities
        
        activityVC.completionWithItemsHandler = {string, bool, items, error in
            
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UIView {
    var width: CGFloat {
        return self.bounds.width
    }
    
    var height: CGFloat {
        return self.bounds.height
    }
}

@IBDesignable
extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        } get { return self.layer.borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        } get { return UIColor(cgColor: layer.borderColor!) }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            if newValue < 0 {
                self.layer.cornerRadius = self.bounds.height / 2
                return
            }
            self.layer.cornerRadius = newValue
        } get { return self.layer.cornerRadius }
    }
}

extension UIColor {
    static var globalTint: UIColor {
        return UIColor(red: 52 / 255, green: 164 / 255, blue: 170 / 255, alpha: 1.0)
    }
}

extension Array {
    var random: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}
