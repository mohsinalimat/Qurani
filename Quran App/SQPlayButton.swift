//
//  SQPlayButton.swift
//  DGDrawRectAnimationTutorial
//
//  Created by Hussein Ryalat on 7/21/16.
//  Copyright © 2016 Danil Gontovnik. All rights reserved.
//

import UIKit
import pop

@IBDesignable class SQCorePlayButton: UIButton {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate(set) var buttonState = SQPlayButtonState.paused
    fileprivate var animationValue: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: -
    // MARK: Methods
    
    func setButtonState(_ buttonState: SQPlayButtonState, animated: Bool) {
        if self.buttonState == buttonState {
            return
        }
        self.buttonState = buttonState
        
        if pop_animation(forKey: "animationValue") != nil {
            pop_removeAnimation(forKey: "animationValue")
        }
        
        let toValue: CGFloat = buttonState.value
        
        if animated {
            let animation = POPBasicAnimation()
            let property = POPAnimatableProperty.property(withName: "animationValue") { (prop) -> Void in
                
                
                
                prop?.readBlock = { (object: Any?, values: UnsafeMutablePointer<CGFloat>?) in
                    if let button = object as? SQCorePlayButton {
                        values![0] = button.animationValue
                    }
                }
                
                prop?.writeBlock = { (object: Any?, values: UnsafePointer<CGFloat>?) in
                    if let button = object as? SQCorePlayButton {
                        button.animationValue = values![0]
                    }
                }
                
                prop?.threshold = 0.01
            }
            
            animation.property = property as? POPAnimatableProperty
            animation.fromValue = NSNumber(value: Float(self.animationValue) as Float)
            animation.toValue = NSNumber(value: Float(toValue) as Float)
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.duration = 0.25
            pop_add(animation, forKey: "percentage")
        } else {
            animationValue = toValue
        }

    }
    
    // MARK: -
    // MARK: Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let height = rect.height
        let startX: CGFloat = 0
        
        let minWidth = rect.width * 0.32
        let aWidth = (rect.width / 2.0 - minWidth) * animationValue
        let width = minWidth + aWidth
        
        let h1 = height / 4.0 * animationValue
        let h2 = height / 2.0 * animationValue
        
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setLineWidth(1)
        
        context?.move(to: CGPoint(x: startX, y: 0.0))
        context?.addLine(to: CGPoint(x: width, y: h1))
        context?.addLine(to: CGPoint(x: width, y: height - h1))
        context?.addLine(to: CGPoint(x: startX, y: height))
        
        context?.move(to: CGPoint(x: rect.width - width, y: h1))
        context?.addLine(to: CGPoint(x: rect.width, y: h2))
        context?.addLine(to: CGPoint(x: rect.width, y: height - h2))
        context?.addLine(to: CGPoint(x: rect.width - width, y: height - h1))
        
        context?.setStrokeColor(tintColor.cgColor)
        context?.setFillColor(tintColor.cgColor)
        
        context?.drawPath(using: .fillStroke)
    }
}

enum SQPlayButtonState: Int {
    case paused
    case playing
    
    var value: CGFloat {
        return (self == .paused) ? 1.0 : 0.0
    }
    
    var reversed: SQPlayButtonState {
        return self == .paused ? .playing : .paused
    }
}

//MARK: -- Container
@IBDesignable class SQPlayButton: UIButton {
    
    var corePlayButton: SQCorePlayButton!
    var buttonState: SQPlayButtonState {
        return corePlayButton.buttonState
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup(){
        corePlayButton = SQCorePlayButton()
        corePlayButton.addTarget(self, action: #selector(SQPlayButton.playButtonPressed), for: .touchUpInside)
        corePlayButton.layer.zPosition = 100
        addSubview(corePlayButton)
        layoutSubviews()
        
        layer.cornerRadius = max(bounds.width, bounds.height) / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        corePlayButton.frame = CGRect(x: 0, y: 0, width: bounds.width * 0.37, height: bounds.height * 0.37)
        corePlayButton.center = CGPoint(x: buttonState == .playing ?  bounds.width / 2 : bounds.width / 2 + (bounds.width / 20), y: bounds.height / 2)
    }
    
    @objc func playButtonPressed() {
        setButtonState(buttonState.reversed, animated: true, shouldSendActions: true)
    }
    
    func setButtonState(_ buttonState: SQPlayButtonState, animated: Bool, shouldSendActions: Bool){
        corePlayButton.setButtonState(buttonState, animated: animated)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutSubviews()
        }) 
        
        if shouldSendActions {
            self.sendActions(for: .valueChanged)
        }
    }
}
