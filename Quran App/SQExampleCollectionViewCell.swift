//
//  SQExampleCollectionViewCell.swift
//  Quran App
//
//  Created by Octupize on 9/6/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import GDLoadingIndicator
import BEMCheckBox



class SQExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var loadingIndicator: GDLoadingIndicator!

    var onFinish: (() -> Void)?
    
    var animationDuration: CGFloat = 0.3
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadingIndicator.setAnimationDuration(animationDuration)
        loadingIndicator.setCircleLineWidth(5)
        loadingIndicator.setCircleColor(UIColor.globalTint)
    }
    
    func beginLoading(){
        loadingIndicator.setProgress(1)
    }
}
