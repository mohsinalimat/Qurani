//
//  SQRegularHeaderView.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/24/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

class SQRegularHeaderView: UIView {
    
    fileprivate var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    var action: (() -> Void)?
    
    class func headerViewWithTitle(_ title: String?, doneButtonAction: (() -> Void)?) -> SQRegularHeaderView {
        
        let headerView = Bundle.main.loadNibNamed(SQRegularHeaderView.className, owner: nil, options: nil)?.first as! SQRegularHeaderView
        
        headerView.title = title
        headerView.action = doneButtonAction
        
        return headerView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    
    func setButtonAsIcon(){
        let constraints = [NSLayoutConstraint.init(item: doneButton, attribute: .width, relatedBy: .equal, toItem: doneButton, attribute: .height, multiplier: 19 / 33, constant: 0.0), NSLayoutConstraint.init(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 15)]
        NSLayoutConstraint.activate(constraints)
        
        doneButton.setImage(UIImage(named: "left"), for: UIControlState())
        doneButton.borderWidth = 0
    }
    
    @IBAction func buttonTap(){
        action?()
    }
}
