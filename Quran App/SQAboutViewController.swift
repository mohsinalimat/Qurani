//
//  SQAboutViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/29/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import MessageUI

class SQAboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.closeButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 4))
        self.view.backgroundColor = Colors.tint
        self.closeButton.tintColor = Colors.tint
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.centerButton.isHidden = !MFMailComposeViewController.canSendMail()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func awesomeButtonTapped(_ sender: AnyObject){        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([kDeveloperEmail])
        composeVC.setSubject(kEmailSubjet)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
}

extension SQAboutViewController {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if error != nil {
            showErrorMessage(ErrorMessages.mailOpen)
        }
        
        if result == MFMailComposeResult.sent {
            showMessage(Messages.mailSent)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
