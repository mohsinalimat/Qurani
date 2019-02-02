//
//  SQAyahPickerViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/3/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import TOScrollBar

private let kCellIdentifierKey = "AyaRepCell"


protocol SQAyahPickerViewControllerDelegate: NSObjectProtocol {
    func ayahPickerViewController(picker: SQAyahPickerViewController, didSelectItemAtIndex index: Int)
}

class SQAyahPickerViewController: SQPickerViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum AyahPickingMode: Int {
        case startIndex = 0,
            endIndex = 1
    }

    var surah: SQSurah!
    var selectionColor: UIColor!
    var pickingMode: AyahPickingMode = .startIndex
   
    var selectedIndex: Int! = -1
    var font: UIFont!
    
    var completedIndexes: [Int] = []
    
    weak var delegate: SQAyahPickerViewControllerDelegate?
    
    lazy var scrollBar: TOScrollBar = {
        let scrollBar = TOScrollBar()
        scrollBar.handleTintColor = Colors.tint
        scrollBar.trackTintColor = Colors.semiWhite
        self.tableView.to_add(scrollBar)
        self.tableView.separatorInset = scrollBar.adjustedTableViewSeparatorInset(forInset: self.tableView.separatorInset)
        return scrollBar
    }()
    
    /* any ayahs whose index less than this value can't be selected.. */
    var beginSelectionIndex: Int = 0
    
    var ayat: [SQAyah] {
        return surah.ayat
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100

        
        selectionColor = Colors.tint
        tableView.backgroundColor = .white
        
        font = UIFont(name: "me_quran", size: SQSettingsController.fontSize())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if pickingMode == .endIndex {
            goTo(beginSelectionIndex)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableView.to_removeScrollbar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goTo(_ index: Int){
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)

    }
}

//MARK: TableView
extension SQAyahPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ayat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierKey) as! SQAyaRepTableViewCell
        let ayaRep = ayat[indexPath.row]
        
        cell.layoutMargins = scrollBar.adjustedTableViewCellLayoutMargins(forMargins: cell.layoutMargins, manualOffset: 15)

        /* if the cell is less than the selected begin index, sooo just disable it :D */
        if indexPath.row <= self.beginSelectionIndex || ( self.pickingMode == .startIndex && indexPath.row == ayat.count - 1){
            cell.contentView.alpha = 0.5
        } else {
            cell.contentView.alpha = 1.0
        }
        
        let labelColor = indexPath.row == selectedIndex ? selectionColor : Colors.contents
        let backgroundColor = indexPath.row == selectedIndex ? selectionColor.withAlphaComponent(0.2) : UIColor.white
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 1.0
        paragraphStyle.alignment = .right
        
        let attributedText = NSAttributedString(string: ayaRep.text, attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: labelColor!, NSFontAttributeName: font])
        
        cell.label.attributedText = attributedText
        cell.cornerLabel.text = "\(ayaRep.index!.localized)"
        cell.backgroundColor = backgroundColor
        cell.button.isSelected = !self.completedIndexes.contains(indexPath.row + 1)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= self.beginSelectionIndex {
            /* the end index can't be smaller than the begin index! */
            showErrorMessage(ErrorMessages.invaildEndIndexSelection)
            return
        }
        
        if pickingMode == .startIndex && indexPath.row == ayat.count - 1 {
            /* can't select the end index!! */
            showErrorMessage(ErrorMessages.invaildStartIndexSelection)
            return
        }
        
        selectedIndex = indexPath.row    
        delegate?.ayahPickerViewController(picker: self, didSelectItemAtIndex: selectedIndex)
        tableView.reloadData()
    }
}
