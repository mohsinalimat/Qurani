//
//  SQPickerViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/8/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

class SQPickerViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!

    
    var index: Int = 0    
    
    var pickerTitle: String? {
        didSet {
            if titleLabel != nil {
                titleLabel.text = pickerTitle
            }
        }
    }
    
    var pickerDetails: String? {
        didSet {
            if detailsLabel != nil {
                detailsLabel.text = pickerDetails
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = pickerTitle
        titleLabel.textColor = Colors.title
        detailsLabel.text = pickerDetails
        detailsLabel.textColor = Colors.tint
        backButton.tintColor = Colors.tint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




