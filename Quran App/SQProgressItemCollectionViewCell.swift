//
//  SQProgressItemCollectionViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/23/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import BEMCheckBox
import GDLoadingIndicator


public var defaultProgressCellsBorderColor: UIColor!

class SQProgressCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var progressView: GDLoadingIndicator!
    
    static let identifier = "PROGRESS"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //self.layer.cornerRadius = max(self.frame.size.width, self.frame.size.height) / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressView.setCircleLineWidth(5)
        progressView.setCircleColor(UIColor.globalTint)
        progressView.setProgress(0.5)
    }
}

class SQCompleteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var completeCheckBox: BEMCheckBox!
    
    static let identifier = "COMPLETE"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
       // self.layer.cornerRadius = max(self.frame.size.width, self.frame.size.height) / 2
    }
}
