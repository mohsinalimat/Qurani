//
//  FittableFontLabel.swift
//
// Copyright (c) 2016 Tom Baranes (https://github.com/tbaranes)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
import UIKit


class LabelWithAdaptiveTextHeight: UILabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        font = fontToFitHeight()
        print(font.pointSize)
    }
    
    // Returns an UIFont that fits the new label's height.
    private func fontToFitHeight() -> UIFont {
        
        var minFontSize: CGFloat = 5 // CGFloat 18
        var maxFontSize: CGFloat = 35     // CGFloat 67
        var fontSizeAverage: CGFloat = 0
        var textAndLabelHeightDiff: CGFloat = 0
        
        while (minFontSize <= maxFontSize) {
            
            fontSizeAverage = minFontSize + (maxFontSize - minFontSize) / 2
            
            // Abort if text happens to be nil
            guard let text = self.text, text.count > 0 else {
                break
            }
            
            let labelText = text as NSString
            let labelHeight = frame.size.height
            
            let testStringHeight = labelText.size(withAttributes:
                [.font: font.withSize(fontSizeAverage)]
                ).height
            
            textAndLabelHeightDiff = labelHeight - testStringHeight
            
            if (fontSizeAverage == minFontSize || fontSizeAverage == maxFontSize) {
                if (textAndLabelHeightDiff < 0) {
                    return font.withSize(fontSizeAverage - 1)
                }
                return font.withSize(fontSizeAverage)
            }
            
            if (textAndLabelHeightDiff < 0) {
                maxFontSize = fontSizeAverage - 1
                
            } else if (textAndLabelHeightDiff > 0) {
                minFontSize = fontSizeAverage + 1
                
            } else {
                return font.withSize(fontSizeAverage)
            }
        }
        return font.withSize(fontSizeAverage)
    }
}

// An UILabel subclass allowing you to automatize the process of adjusting the font size.
@IBDesignable
open class FittableFontLabel: UILabel {
    
    // MARK: Properties
    /// If true, the font size will be adjusted each time that the text or the frame change.
    @IBInspectable public var autoAdjustFontSize: Bool = true
    
    /// The biggest font size to use during drawing. The default value is the current font size
    @IBInspectable public var maxFontSize: CGFloat = CGFloat.nan
    
    /// The scale factor that determines the smallest font size to use during drawing. The default value is 0.1
    @IBInspectable public var minFontScale: CGFloat = CGFloat.nan
    
    /// UIEdgeInset
    @IBInspectable public var leftInset: CGFloat = 0
    @IBInspectable public var rightInset: CGFloat = 0
    @IBInspectable public var topInset: CGFloat = 0
    @IBInspectable public var bottomInset: CGFloat = 0
    
    // MARK: Properties override
    open override var text: String? {
        didSet {
            adjustFontSize()
        }
    }
    
    open override var frame: CGRect {
        didSet {
            adjustFontSize()
        }
    }
    
    // MARK: Private
    var isUpdatingFromIB = false
    
    // MARK: Life cycle
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        isUpdatingFromIB = autoAdjustFontSize
        adjustFontSize()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        isUpdatingFromIB = autoAdjustFontSize
        adjustFontSize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isUpdatingFromIB {
            adjustFontSize()
        }
        isUpdatingFromIB = false
    }
    
    // MARK: Insets
    open override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
}

// MARK: Helpers
extension FittableFontLabel {
    
    private func adjustFontSize() {
        if autoAdjustFontSize {
            fontSizeToFit(maxFontSize: maxFontSize, minFontScale: minFontScale)
        }
    }
}

extension UILabel {
    
    /**
     Resize the font to make the current text fit the label frame.
     - parameter maxFontSize:  The max font size available
     - parameter minFontScale: The min font scale that the font will have
     - parameter rectSize:     Rect size where the label must fit
     */
    public func fontSizeToFit(maxFontSize: CGFloat = 100, minFontScale: CGFloat = 0.1, rectSize: CGSize? = nil) {
        guard let unwrappedText = self.text else {
            return
        }
        
        let newFontSize = fontSizeThatFits(text: unwrappedText, maxFontSize: maxFontSize, minFontScale: minFontScale, rectSize: rectSize)
        font = font.withSize(newFontSize)
    }
    
    /**
     Returns a font size of a specific string in a specific font that fits a specific size
     - parameter text:         The text to use
     - parameter maxFontSize:  The max font size available
     - parameter minFontScale: The min font scale that the font will have
     - parameter rectSize:     Rect size where the label must fit
     */
    public func fontSizeThatFits(text string: String, maxFontSize: CGFloat = 100, minFontScale: CGFloat = 0.1, rectSize: CGSize? = nil) -> CGFloat {
        let maxFontSize = maxFontSize.isNaN ? 100 : maxFontSize
        let minFontScale = minFontScale.isNaN ? 0.1 : minFontScale
        let minimumFontSize = maxFontSize * minFontScale
        let rectSize = rectSize ?? bounds.size
        guard !string.isEmpty else {
            return self.font.pointSize
        }
        
        let constraintSize = numberOfLines == 1 ?
            CGSize(width: CGFloat.greatestFiniteMagnitude, height: rectSize.height) :
            CGSize(width: rectSize.width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedFontSize = binarySearch(string: string, minSize: minimumFontSize, maxSize: maxFontSize, size: rectSize, constraintSize: constraintSize)
        return (calculatedFontSize * 10.0).rounded(.down) / 10.0
    }
    
}

// MARK: - Helpers
extension UILabel {
    
    private func currentAttributedStringAttributes() -> [NSAttributedString.Key: Any] {
        var newAttributes = [NSAttributedString.Key: Any]()
        attributedText?.enumerateAttributes(in: NSRange(0..<(text?.count ?? 0)), options: .longestEffectiveRangeNotRequired, using: { attributes, _, _ in
            newAttributes = attributes
        })
        return newAttributes
    }
    
}

// MARK: - Search
extension UILabel {
    
    private enum FontSizeState {
        case fit, tooBig, tooSmall
    }
    
    private func binarySearch(string: String, minSize: CGFloat, maxSize: CGFloat, size: CGSize, constraintSize: CGSize) -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        var attributes = currentAttributedStringAttributes()
        attributes[NSAttributedString.Key.font] = font.withSize(fontSize)
        
        let rect = string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let state = numberOfLines == 1 ? singleLineSizeState(rect: rect, size: size) : multiLineSizeState(rect: rect, size: size)
        
        // if the search range is smaller than 0.1 of a font size we stop
        // returning either side of min or max depending on the state
        let diff = maxSize - minSize
        guard diff > 0.1 else {
            switch state {
            case .tooSmall:
                return maxSize
            default:
                return minSize
            }
        }
        
        switch state {
        case .fit: return fontSize
        case .tooBig: return binarySearch(string: string, minSize: minSize, maxSize: fontSize, size: size, constraintSize: constraintSize)
        case .tooSmall: return binarySearch(string: string, minSize: fontSize, maxSize: maxSize, size: size, constraintSize: constraintSize)
        }
    }
    
    private func singleLineSizeState(rect: CGRect, size: CGSize) -> FontSizeState {
        if rect.width >= size.width + 10 && rect.width <= size.width {
            return .fit
        } else if rect.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }
    
    private func multiLineSizeState(rect: CGRect, size: CGSize) -> FontSizeState {
        // if rect within 10 of size
        if rect.height < size.height + 10 &&
            rect.height > size.height - 10 &&
            rect.width > size.width + 10 &&
            rect.width < size.width - 10 {
            return .fit
        } else if rect.height > size.height || rect.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }
    
}
