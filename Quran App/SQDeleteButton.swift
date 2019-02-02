//
//  SQDeleteButton.swift
//  Quran App
//
//  Created by Hussein Ryalat on 2/1/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit

@IBDesignable class SQDeleteButton: UIButton {

    @IBInspectable var roundBackgroundColor: UIColor = UIColor.alizarin {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let bounds = self.bounds
        let padding = bounds.width * 0.25
        
        
        let context = UIGraphicsGetCurrentContext()
        context?.addEllipse(in: bounds)
        context?.setFillColor(roundBackgroundColor.cgColor)
        context?.drawPath(using: .fill)
        
        context?.beginPath()
        context?.addLines(between: [CGPoint(x: bounds.minX + padding, y: bounds.midY), CGPoint(x: bounds.maxX - padding, y: bounds.midY)])
        context?.setLineWidth(lineWidth)
        context?.setLineJoin(.round)
        context?.setLineCap(.round)
        context?.setStrokeColor(tintColor.cgColor)
        context?.drawPath(using: .stroke)
    }
    
    override func prepareForInterfaceBuilder() {
        setNeedsDisplay()
    }
}
