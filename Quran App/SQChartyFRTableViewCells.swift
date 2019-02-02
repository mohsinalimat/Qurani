//
//  SQChartyFRTableViewCells.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/26/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import GDLoadingIndicator
import BEMCheckBox

class SQProgressFRTableViewCell: UITableViewCell {
    
    @IBOutlet weak var progressView: GDLoadingIndicator!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressView.setCircleLineWidth(5)
        progressView.setCircleColor(UIColor.globalTint)
        progressView.setProgress(0.5)
    }
}

class SQCompletedFRTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}
