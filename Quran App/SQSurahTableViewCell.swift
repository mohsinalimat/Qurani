//
//  SQSurahTableViewCell.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/8/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import DynamicButton
import GDLoadingIndicator

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}

class SQSurahTableViewCell: UITableViewCell {
    
    var onDownloadButtonTap: (() -> Void)?
    
    /* regular state.. */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    /* resume downloading or download from start.. */
    @IBAction func downloadButtonTapped(){
        self.onDownloadButtonTap?()
    }
}
