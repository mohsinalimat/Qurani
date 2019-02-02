//
//  SQTabBarController.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/13/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit
import LUNTabBarController

class SQTabBarController: LUNTabBarController {
    
    var fadeAnimationController: SKFadeTransition! = SKFadeTransition()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.layer.borderWidth = 0
        
        self.tabBar.layer.borderColor = Colors.semiWhite.cgColor
        self.tabBar.tintColor = Colors.tint
        
        heroTabBarAnimationType = .fade
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var floatingContentHeight: CGFloat {
        get {
           return 500 / 568 * view.height
        } set {
            super.floatingContentHeight = newValue
        }
    }
    
    override func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animationController = super.tabBarController(tabBarController, animationControllerForTransitionFrom: fromVC, to: toVC)
        
        if animationController == nil {
            animationController = fadeAnimationController
            fadeAnimationController.transitionDuration = TimeInterval(self.transitionDuration)
        }
        
        return animationController
    }
}
