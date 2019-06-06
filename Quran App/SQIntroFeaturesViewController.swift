//
//  SQIntroFeaturesViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/5/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit

class SQIntroFeaturesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var features: [SQAppFeature] = SQAppFeature.features()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension SQIntroFeaturesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SQFeatureTableViewCell
        let feature = features[indexPath.row]
        
        cell.featureImageView.image = feature.image
        cell.featureLabel.text = feature.text
        
        return cell
    }
}
