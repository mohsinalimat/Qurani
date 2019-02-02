//
//  SQChartDetailsViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 1/26/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit
import BEMCheckBox
import GDLoadingIndicator

class SQChartDetailsViewController: UIViewController {

    var progressContainer: SQProgressContainer!

    var progressItems: [SQProgressItem]! {
        return progressContainer.progressItems
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var progressView: GDLoadingIndicator!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableViewTitle: UILabel!
    
    fileprivate var _shouldAnimateCells = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.isHeroEnabled = true
        tableView.heroModifiers = []

        progressView.setCircleLineWidth(3)
        progressView.setCircleColor(Colors.semiWhite)
        progressView.setFillerColor(Colors.tint)
        
        checkBox.onFillColor = Colors.tint
        checkBox.onTintColor = Colors.tint
        checkBox.onCheckColor = .white
        
        titleLabel.textColor = Colors.title
        backButton.tintColor = Colors.tint
        
        tableViewTitle.textColor = Colors.tint
        
        progressView.heroID = "\(progressContainer.displayName)Progress"
        checkBox.heroID = "\(progressContainer.displayName)CheckBox"
        titleLabel.heroID = "\(progressContainer.displayName)Title"
        
        updateViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _shouldAnimateCells = true
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _shouldAnimateCells = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateViews(){
        let progress = self.progressContainer.progress
        self.checkBox.isHidden = progress < 1
        self.progressView.isHidden = progress == 1
        self.progressView.setProgress(CGFloat(progress))

        self.titleLabel.text = self.progressContainer.displayName
        self.tableView.reloadData()
    }
}

extension SQChartDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.progressItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let progressItem = self.progressItems[indexPath.row]
        let progress = progressItem.progress
        if progress < 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell") as! SQProgressFRTableViewCell
            cell.progressView.setProgress(CGFloat(progress))
            cell.progressView.setCircleLineWidth(1)
            cell.progressView.setCircleColor(Colors.semiWhite)
            cell.progressView.setFillerColor(Colors.tint)
            
            cell.titleLabel.text = progressItem.displayName
            cell.titleLabel.textColor = Colors.contents
            cell.subtitleLabel.text = progressItem.progressMessage
            cell.subtitleLabel.textColor = Colors.lightGray
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell") as! SQCompletedFRTableViewCell
            
            cell.titleLabel.text = progressItem.description
            cell.titleLabel.textColor = Colors.contents

            cell.subtitleLabel.text = progressItem.progressMessage
            cell.subtitleLabel.textColor = Colors.lightGray
            cell.checkBox.onFillColor = Colors.tint
            cell.checkBox.onCheckColor = .white
            cell.checkBox.onTintColor = Colors.tint
            
            return cell
        }
    }
}
