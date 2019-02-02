//
//  SQFavoritedRangeCollectionViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/29/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import BEMCheckBox


class SQFavoritedRangeCollectionViewCell: UICollectionViewCell {
    
    enum State: Int {
        case normal = 0, delete = 1, completed = 2
    }
    
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var deleteAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setState(state: .normal, animated: false)
    }
    
    func setState(state: State, animated: Bool, delay: TimeInterval = 0.0){
        if !animated {
            checkbox.alpha = state != .completed ? 0 : 1
            button.alpha = state != .normal ? 0 : 1
            deleteButton.alpha = state != .delete ? 0 : 1
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .allowAnimatedContent, animations: {
            self.checkbox.alpha = state != .completed ? 0 : 1
            self.button.alpha = state != .normal ? 0 : 1
            self.deleteButton.alpha = state != .delete ? 0 : 1
        }, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(){
        self.deleteAction?()
    }
}
