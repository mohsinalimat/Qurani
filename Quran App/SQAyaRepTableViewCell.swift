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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func buttonTap(_ sender: AnyObject) {
        button.isSelected ? button.deselect() : button.select()
        onButtonTap?(button.isSelected)
    }
}



