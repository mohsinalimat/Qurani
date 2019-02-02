//
//  SQCompletionViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/10/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

private let sharedFont = UIFont(name: "me_quran", size: 21)

protocol SQCompletionViewControllerDelegate: NSObjectProtocol {
    func completionViewController(viewController: SQCompletionViewController, shouldProceed shouldSave: Bool)
}

class SQCompletionViewController: UIViewController {
    
    @IBOutlet weak var beginAyahTextView: UITextView!
    @IBOutlet weak var endAyahTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var delegate: SQCompletionViewControllerDelegate?
    
    var surah: SQSurah! {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
    
    var beginAyahIndex: Int = -1 {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
    
    var endAyahIndex: Int = -1 {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateViews()
        
        yesButton.cornerRadius = yesButton.width / 2
        noButton.cornerRadius = noButton.width / 2
        
        titleLabel.textColor = .white
        separatorView.backgroundColor = UIColor.white
        
        for textView in [beginAyahTextView, endAyahTextView] {
            textView?.font = sharedFont
            textView?.textAlignment = .right
            textView?.textColor = Colors.contents
        }
        
        self.view.backgroundColor = Colors.tint
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        self.yesButton.cornerRadius = yesButton.height / 2
        self.noButton.cornerRadius = noButton.height / 2
    }

    func updateViews(){
        titleLabel.text = surah.name
        
        if beginAyahIndex == -1 || endAyahIndex == -1 {
            print("parameters are not provided!")
            return
        }
        
        beginAyahTextView.text = surah.ayat[beginAyahIndex].text
        endAyahTextView.text = surah.ayat[endAyahIndex].text
    }
    
    @IBAction func yesTap(){
        self.delegate?.completionViewController(viewController: self, shouldProceed: true)
    }
    
    @IBAction func noTap(){
        self.delegate?.completionViewController(viewController: self, shouldProceed: false)
    }
}
