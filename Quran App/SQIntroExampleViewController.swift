//
//  SQIntroExampleViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 9/5/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit

class SQIntroExampleViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var titles: [String]! = ["الآيات من ١ إلى ٢٥","الآيات من ١١ إلى ٥٠","الآيات من ٥١ إلى ٨٠","الآيات من ١٨ إلى ١١٠"]
    var booleans: [Bool] = [true, true, true, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.heroModifiers = [.cascade]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension SQIntroExampleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SQExampleCollectionViewCell
        
        cell.layer.borderColor = UIColor.clouds.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        cell.heroModifiers = [.fade, .scale(0.5)]
        
        cell.label.text = titles[indexPath.row]
        cell.loadingIndicator.setCircleLineWidth(1)
        cell.loadingIndicator.setCircleColor(Colors.semiWhite)
        cell.loadingIndicator.setProgress(CGFloat(0.5))
        cell.loadingIndicator.setFillerColor(Colors.tint)
    
        cell.checkbox.onFillColor = Colors.tint
        cell.checkbox.onCheckColor = .white
        cell.checkbox.onTintColor = Colors.tint
        
        cell.loadingIndicator.isHidden = booleans[indexPath.row]
        cell.checkbox.isHidden = !booleans[indexPath.row]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! SQExampleCollectionViewCell
        cell.beginLoading()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.width, height: (collectionView.height - CGFloat(10 * titles.count)) / CGFloat(titles.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}
