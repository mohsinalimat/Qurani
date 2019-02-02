//
//  SlideInPresentationManager.swift
//  PresentationController Demo
//
//  Created by Hussein Ryalat on 1/27/17.
//  Copyright © 2017 Sketch Studio. All rights reserved.
//

import UIKit


class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate, UIAdaptivePresentationControllerDelegate {
        
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController =  SlideInPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact {
            return .overFullScreen
        } else {
            return .none
        }
    }
}
