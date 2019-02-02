//
//  SKFadeTransition.swift
//  Quran App
//
//  Created by Hussein Ryalat on 7/13/16.
//  Copyright © 2016 Sketch Studio. All rights reserved.
//

import UIKit

class SKFadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionDuration: TimeInterval = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let containerView = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        
        containerView.addSubview(toVC!.view)
        containerView.addSubview(fromVC!.view)
        
        UIView.animate(withDuration: duration, animations: { 
                fromVC?.view.alpha = 0.0
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromVC?.view.alpha = 1
        }) 
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
}
