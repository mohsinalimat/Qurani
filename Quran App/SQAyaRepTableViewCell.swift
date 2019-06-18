//
//  SQAyaRepTableViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/18/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import YYText
import DOFavoriteButton

class SQAyaRepTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cornerLabel: UILabel!
    @IBOutlet weak var button: DOFavoriteButton!

    var onButtonTap: ((_ selected: Bool) -> Void)?
    
    var textFont: UIFont!
    
    @IBAction func buttonTap(_ sender: AnyObject) {
        button.isSelected ? button.deselect() : button.select()
        onButtonTap?(button.isSelected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textFont = label.font
    }
    
    func set(text: String, color: UIColor){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.alignment = .right
        
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: textFont])
        
        label.attributedText = attributedText
    }
}



