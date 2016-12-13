//
//  RPopupController.swift
//  cloudadfp
//
//  Created by WISA on 2016. 9. 21..
//  Copyright © 2016년 WISA. All rights reserved.
//

import UIKit

@objc protocol RPopupControllerDelegate {
    optional func dismissKeyboard()
    func autoKeyboardScroll() -> Bool
}
class RPopupController : UIViewController{

    
    
    var contentController:UIViewController?
    var popupScrollView : UIScrollView?
    let POPUP_GAP_WIDTH:CGFloat = 32
    let POPUP_GAP:CGFloat = 100
    var openKeyboard = false
    var delegate:UIViewController?
    var resp:((String)->Void)?
    var cancelabld:Bool = true;
    init(controlller:UIViewController){
        super.init(nibName: nil, bundle: nil)
        self.contentController = controlller
        initController(SCREEN_HEIGHT - POPUP_GAP)
    }
    init(controlller:UIViewController,height:CGFloat){
        super.init(nibName: nil, bundle: nil)
        self.contentController = controlller
        initController(height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initController(height:CGFloat){
        self.view.frame = UIScreen.mainScreen().bounds
        
        
        if height == 0{
            self.contentController!.view.frame = CRectChangeWidth(self.contentController!.view.frame, width: SCREEN_WIDTH - POPUP_GAP_WIDTH)
            self.contentController!.view.frame = CRectChangeHeight(self.contentController!.view.frame,height: 100)
            self.contentController!.view.center = self.view.center
        }else{
            self.contentController!.view.frame = CRectChangeWidth(self.contentController!.view.frame, width: SCREEN_WIDTH - POPUP_GAP_WIDTH)
            self.contentController!.view.frame = CRectChangeHeight(self.contentController!.view.frame,height: height)
            self.contentController!.view.center = self.view.center
            
        } 
        
        self.view.opaque = false
        self.modalPresentationStyle = .OverCurrentContext
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.contentController!.view.alpha = 0
        self.contentController!.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
//        self.contentController!.view.layer.cornerRadius = 5
        
        self.popupScrollView = UIScrollView(frame: self.view.bounds)
        self.popupScrollView!.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.popupScrollView?.contentSize = self.view.frame.size
        self.popupScrollView!.addSubview(self.contentController!.view)
        self.view.addSubview(self.popupScrollView!)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(RPopupController.singleTapEvent(_:)))
        self.popupScrollView?.addGestureRecognizer(gesture)
        
        self.addChildViewController(self.contentController!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = self.contentController as? RPopupControllerDelegate {
            if delegate.autoKeyboardScroll() {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPopupController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPopupController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
            }
        }

    }
    
    
    
    func dismissPopup(completion: (() -> Void)?) {
        
        if let delegate = self.contentController as? RPopupControllerDelegate {
            if delegate.autoKeyboardScroll() {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object:  nil)
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object:  nil)
            }
        }
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            self.contentController!.view.alpha = 0
            self.contentController!.view.transform = CGAffineTransformMakeScale(0.5, 0.5)
        }) { (Bool) in
            self.dismissViewControllerAnimated(false, completion: completion)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                self.contentController!.view.alpha = 1
                self.contentController!.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (Bool) in
        }
    }
    
    
    func keyboardWillShow(notification:NSNotification){
        if self.openKeyboard {
            return
        }
        let keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        self.popupScrollView?.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height + keyboard!.height)
        self.openKeyboard = true
        UIView.animateWithDuration(0.3, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.popupScrollView!.contentOffset = CGPointMake(0, keyboard!.height)
        }) { (Bool) in
                
        }
 
        
    }
    
    func keyboardWillHide(notification:NSNotification){
        if self.openKeyboard {
            openKeyboard = false
            UIView.animateWithDuration(0.3, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.popupScrollView!.contentOffset = CGPointMake(0, 0)
                self.popupScrollView?.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.height)
                
            }) { (Bool) in
                
            }
        }
    }

    
    func singleTapEvent(gesture:UITapGestureRecognizer){
        let location = gesture.locationInView(self.view)
        if openKeyboard {
            if let delegate = self.contentController as? RPopupControllerDelegate {
                delegate.dismissKeyboard?()
            }
            return
        }
        if CGRectContainsPoint(self.contentController!.view.frame, location) {
        }else{
            if(self.cancelabld){
                self.dismissPopup(nil)
            }
        }
    }
    
 
    func changeSize(height:CGFloat) {
        self.contentController!.view.alpha = 0
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.contentController!.view.alpha = 1
            self.contentController!.view.frame = CRectChangeWidth(self.contentController!.view.frame, width: SCREEN_WIDTH - self.POPUP_GAP_WIDTH)
            self.contentController!.view.frame = CRectChangeHeight(self.contentController!.view.frame,height: height)
            self.contentController!.view.center = self.view.center

            
        }) { (Bool) in
            
        }
    }
    
    func popupWidth() -> CGFloat {
        return SCREEN_WIDTH - POPUP_GAP_WIDTH
    }
}
