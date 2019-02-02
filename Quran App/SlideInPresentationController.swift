//
//  SlideInPresentationController.swift
//  PresentationController Demo
//
//  Created by Hussein Ryalat on 1/27/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    
    fileprivate var dimmingView: UIView!
    
    
//    fileprivate let modalSize: CGSize = CGSize(width: 280.0, height: 460.0) // 0.875, 0.80
    //var edgeInsets: UIEdgeInsets = UIEdgeInsetsMake(modalSize.height / 2, 20, modalSize.height / 2, 20)
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = CGRect.zero
        
        let modalSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        frame.size = modalSize
        
        
        frame.origin.x = (containerView!.frame.width - modalSize.width ) / 2
        frame.origin.y = (containerView!.frame.height - modalSize.height ) / 2

        return frame
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        setupDimmingView()
    }
    
    fileprivate func setupDimmingView(){
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        dimmingView.addGestureRecognizer(recognizer)
    }
    
    dynamic func handleTap(sender: UITapGestureRecognizer){
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        
        coordinator.animate(alongsideTransition: { (_) in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width * 0.875, height: parentSize.height * 0.8)
        //return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
    }
}
