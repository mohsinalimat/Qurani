//
//  SQFloatingViewController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/13/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import LUNTabBarController

class SQFloatingViewController: UIViewController, LUNTabBarFloatingControllerAnimatedTransitioning {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    var titles: [String]! = []
    var images: [UIImage]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.textColor = Colors.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "money ya bebe :D" {
            let destination = segue.destination as! SQStoreViewController
            destination.action = .restore
        }
    }
    
    func setupInfo(){
        titles = [Labels.settings, Labels.aboutTheApp]
        images = [Icons.settings.image, Icons.about.image]
    }
    
    //MARK: LUNTabBarFloatingControllerAnimatedTransitioning
    
    func floatingViewControllerStartedAnimatedTransition(_ isPresenting: Bool) {
    }
    
    func keyframeAnimation(forFloatingViewControllerAnimatedTransition isPresenting: Bool) -> (() -> Void)! {
        return {
            let backgroundColor = isPresenting ? UIColor.white.withAlphaComponent(0.95) : UIColor.white
            self.contentView.backgroundColor = backgroundColor            
        }
    }
    
    
    func floatingViewControllerFinishedAnimatedTransition(_ isPresenting: Bool, wasCompleted: Bool) {
        
    }
}

extension SQFloatingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as! SQMoreOptionTableViewCell
        cell.titleLabel.text = titles[indexPath.row]
        cell.titleLabel.textColor = Colors.tint
        if images.count > 0 && indexPath.row < images.count {
            cell.rightImageView.image = images[indexPath.row]
            cell.rightImageView.tintColor = Colors.tint
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = titles[indexPath.row]
        actionForTitle(action)
    }
    
    func actionForTitle(_ title: String) {
        switch title {
        case titles[0]:
            goSettings()
            return
        case titles[1]:
            goAbout()
            return
        case titles[2]:
            restore()
            return
        default:
            return
        }
    }
    
    func goSettings(){
        let nav = UINavigationController(rootViewController: SQSettingsViewController())
        nav.isNavigationBarHidden = true

        present(nav, animated: true, completion: nil)
    }
    
    func goAbout(){
        let about = SQAboutViewController.createFromMainStoryboardWithIdentifier("About")
        present(about!, animated: true, completion: nil)
    }
    
    func restore(){
        self.performSegue(withIdentifier: "store", sender: self)
    }
}
