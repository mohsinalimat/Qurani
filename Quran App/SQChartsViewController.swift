//
//  SQProgressesViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 5/23/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class SQChartsViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    fileprivate let kCellsPadding: CGFloat = 50
    fileprivate let kCellsPerRow: CGFloat = 2
    
    var numberFormatter: NumberFormatter!
    
    var progressContainers: [SQProgressContainer]! {
        return SQProgressItemsManager.shared.progressContainers
    }
    
    //MARK: Outlets
    
    @IBOutlet weak var emptyStateStackView: UIStackView!
    
    var currentPage: Int = 0 {
        didSet {
            if currentPage < 0 || currentPage >= self.progressContainers.count {
                return
            }
            
            /* hide the share button if needed.. */
            self.shareButton.isHidden = self.progressContainers.count == 0

            
            if progressContainers.count == 0 {
                self.mainLabel.text = ""
                self.detailsLabel.text = ""
                
                return
            }
            
            let item = self.progressContainers[self.currentPage]
            
            self.mainLabel.text = item.displayName
            self.mainLabel.heroID = "\(item.displayName)Title"
            
            self.detailsLabel.text = item.progressMessage
            self.detailsLabel.heroID = "\(item.displayName)Details"

        }
    }
    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    @IBOutlet weak var contentsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.emptyDataSetSource = self
        self.collectionView.emptyDataSetDelegate = self
        
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.overlap(visibleOffset: 30)
        
        currentPage = 0
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.locale = Locale.init(identifier: "ar")
        
        
        mainLabel.textColor = Colors.title
        detailsLabel.textColor = Colors.lightGray
        shareButton.setTitleColor(Colors.tint, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* hide the share button if needed.. */
        self.shareButton.isHidden = self.progressContainers.count == 0
        self.emptyStateStackView.isHidden = self.progressContainers.count != 0

        
        if progressContainers.count == 0 {
            self.mainLabel.text = ""
            self.detailsLabel.text = ""
            self.collectionView.reloadData()
            return
        }
        
        
        let item = self.progressContainers[self.currentPage] as! SQSurahInfo
        
        self.mainLabel.text = item.displayName
        self.detailsLabel.text = item.progressMessage
        self.collectionView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
}

extension SQChartsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progressContainers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = progressContainers[indexPath.row]
        let progress = item.progress
        if progress < 1 { // in progress
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SQProgressCollectionViewCell.identifier, for: indexPath) as! SQProgressCollectionViewCell
            
            cell.progressView.setCircleLineWidth(3)
            cell.progressView.setCircleColor(Colors.semiWhite)
            cell.progressView.setProgress(CGFloat(progress))
            cell.progressView.setFillerColor(Colors.tint)
            cell.progressView.heroID = "\(item.displayName)Progress"
            
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SQCompleteCollectionViewCell.identifier, for: indexPath) as! SQCompleteCollectionViewCell
            cell.completeCheckBox.heroID = "\(item.displayName)CheckBox"
            cell.heroModifiers = [.masksToBounds(false)]
            cell.completeCheckBox.onFillColor = Colors.tint
            cell.completeCheckBox.onTintColor = Colors.tint
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openDetails(for: progressContainers[indexPath.row])
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    @IBAction func buttonTap(){
        share(progressContainer: self.progressContainers[currentPage])
    }
    
    @IBAction func viewTap(sender: UITapGestureRecognizer){
        /* open the chart item details.. */
        if self.progressContainers.count == 0 {
            return
        }
        
        openDetails(for: progressContainers[currentPage])
    }
    
    func openDetails(for container: SQProgressContainer){
        let chartDetailsVC = SQChartDetailsViewController.create(from: "Charts", withIdentifier: "ChartDetails")
        chartDetailsVC?.progressContainer = container
        present(chartDetailsVC!, animated: true, completion: nil)
    }
    
    func share(progressContainer: SQProgressContainer){
        let surah = progressContainer as! SQSurahInfo
        let shareText = Sharing.shareMessage(completed: surah.completedAyahs.count, total: surah.ayat.count, surahName: surah.surahName!)
        
        let objectsToShare = [shareText]
        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.completionWithItemsHandler = {string, bool, items, error in }
        
        activityVC.popoverPresentationController?.sourceView = self.view
        let frame = self.view.convert(shareButton.frame, from: contentsView)
        activityVC.popoverPresentationController?.sourceRect = frame
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
}
