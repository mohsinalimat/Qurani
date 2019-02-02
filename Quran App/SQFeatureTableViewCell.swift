//
//  SQFeatureTableViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/5/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit

class SQFeatureTableViewCell: UITableViewCell {
    
    @IBOutlet weak var featureImageView: UIImageView!
    @IBOutlet weak var featureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
