//
//  SQٍSettingsViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/24/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import Bohr

private let kHeaderViewHeight: CGFloat = 100

var headerViewHeight: CGFloat {
    return UIDevice.current.userInterfaceIdiom == .phone ? 100 : 140
}

class SQSettingsViewController: BOTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.backgroundColor = .white
        tableView.separatorColor = Colors.semiWhite
        tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func setup() {
        addHeaderView()
        
        addSection(BOTableViewSection.init(headerTitle: "", handler: { (section) in
            section?.addCell(BOChoiceTableViewCell.init(title: FontSizeType.name, key: SettingsKeys.FontSize, handler: { (cell) in
                
                let cell = cell as! BOChoiceTableViewCell
                cell.options = FontSizeType.allTypes().map { $0.title() }
                
                let destinationViewController = SQSettingOptionsTableViewController.init(key: SettingsKeys.FontSize, titles: cell.options as! [String])
                destinationViewController.title = FontSizeType.name
                cell.destinationViewController = destinationViewController
            }))
            
            section?.addCell(BOSwitchTableViewCell.init(title: "تحديد المقروئات كحفظ تلقائيا", key: SettingsKeys.AutoComplete, handler: { (cell) in
                
            }))
        }))
        
        addSection(BOTableViewSection.init(headerTitle: "", handler: { (section) in
                        
            section?.addCell(BOSwitchTableViewCell.init(title: "إعادة التشغيل عند الأنتهاء", key: SettingsKeys.RepeatOnFinish, handler: { (cell) in
            
                
            }))
            
        }))
    }

    func addHeaderView(){
        weak var weakSelf = self
        let headerView = SQRegularHeaderView.headerViewWithTitle(Labels.settings) {
            weakSelf?.dismiss()
        }
        
        let fontSize: CGFloat = ( traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ) ? 50 : 32
        
        headerView.titleLabel.textColor = Colors.title
        headerView.titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        headerView.separatorView.backgroundColor = Colors.semiWhite
        headerView.doneButton.tintColor = Colors.tint
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: headerViewHeight)
        tableView.tableHeaderView = headerView
    }
}

//MARK: OptionsViewController
class SQSettingOptionsTableViewController: BOTableViewController {
    
    var key: String!
    var options: [String]!
    
    var footerText: String! = ""
    
    override var title: String? {
        didSet {
            if _viewLoaded {
                let headerView = tableView.tableHeaderView as! SQRegularHeaderView
                headerView.titleLabel.text = title
            }
        }
    }
    
    fileprivate var _viewLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _viewLoaded = true

        tableView.backgroundColor = .white
        tableView.separatorColor = Colors.semiWhite
        tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
        addHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    init(key: String, titles: [String]){
        self.key = key
        self.options = titles
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        
        addSection(BOTableViewSection(headerTitle: nil, handler: { (section) -> Void in
            section?.footerTitle = self.footerText
            for (index, option) in self.options.enumerated() {
                section?.addCell(BOOptionTableViewCell(title: option, key: self.key, handler: { cell in
                    let cell = cell as! BOOptionTableViewCell
                    cell.tag = index
                }))
            }
        }))
    }
    
    func addHeaderView(){
        weak var weakSelf = self
        let headerView = SQRegularHeaderView.headerViewWithTitle(title) {
            weakSelf?.popNavigationController()
        }
        
        let fontSize: CGFloat = ( traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ) ? 50 : 32

        
        headerView.titleLabel.textColor = Colors.title
        headerView.titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        headerView.separatorView.backgroundColor = Colors.semiWhite
        headerView.doneButton.tintColor = Colors.tint
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: headerViewHeight + 30)
        headerView.setButtonAsIcon()
        tableView.tableHeaderView = headerView
    }
}
