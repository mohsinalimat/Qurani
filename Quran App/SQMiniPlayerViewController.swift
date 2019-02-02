//
//  SQMiniPlayerViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/21/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import LNPopupController

class SQMiniPlayerViewController: LNPopupCustomBarViewController {
    
    @IBOutlet weak var progressView: SQLinearProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override var wantsDefaultPanGestureRecognizer: Bool {
        return true
    }
    
    override var wantsDefaultTapGestureRecognizer: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        preferredContentSize = CGSize(width: -1, height: 100)
        
        progressView.barColor = Colors.tint
        progressView.trackColor = Colors.semiWhite
        
        titleLabel.textColor = Colors.tint
        subtitleLabel.textColor = Colors.lightGray
        arrowImageView.tintColor = Colors.lightGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func popupItemDidUpdate() {
        /* update the views.. */
        self.titleLabel.text = self.containingPopupBar.popupItem?.title
        self.subtitleLabel.text = self.containingPopupBar.popupItem?.subtitle
        self.progressView.progressValue = CGFloat(self.containingPopupBar.popupItem!.progress) * 100
    }

}
