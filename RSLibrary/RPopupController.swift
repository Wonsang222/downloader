//
//  RPopupController.swift
//  cloudadfp
//
//  Created by WISA on 2016. 9. 21..
//  Copyright © 2016년 WISA. All rights reserved.
//

import UIKit

@objc protocol RPopupControllerDelegate {
    @objc optional func dismissKeyboard()
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
    var cancelable:Bool = true;
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
    
    func initController(_ height:CGFloat){
        self.view.frame = UIScreen.main.bounds
        
        
        if height == 0{
            self.contentController!.view.frame = CRectChangeWidth(self.contentController!.view.frame, width: SCREEN_WIDTH - POPUP_GAP_WIDTH)
            self.contentController!.view.frame = CRectChangeHeight(self.contentController!.view.frame,height: 100)
            self.contentController!.view.center = self.view.center
        }else{
            self.contentController!.view.frame = CRectChangeWidth(self.contentController!.view.frame, width: SCREEN_WIDTH - POPUP_GAP_WIDTH)
            self.contentController!.view.frame = CRectChangeHeight(self.contentController!.view.frame,height: height)
            self.contentController!.view.center = self.view.center
            
        } 
        
        self.view.isOpaque = false
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.contentController!.view.alpha = 0
        self.contentController!.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        self.contentController!.view.layer.cornerRadius = 5
        
        self.popupScrollView = UIScrollView(frame: self.view.bounds)
        self.popupScrollView!.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.popupScrollView?.contentSize = self.view.frame.size
        self.popupScrollView!.addSubview(self.contentController!.view)
        self.view.addSubview(self.popupScrollView!)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(RPopupController.singleTapEvent(gesture:)))
        self.popupScrollView?.addGestureRecognizer(gesture)
        
        self.addChildViewController(self.contentController!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let delegate = self.contentController as? RPopupControllerDelegate {
            if delegate.autoKeyboardScroll() {
                NotificationCenter.default.addObserver(self, selector: #selector(RPopupController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(RPopupController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            }
        }

    }
    
    
    
    func dismissPopup(_ completion: (() -> Void)?) {
        
        if let delegate = self.contentController as? RPopupControllerDelegate {
            if delegate.autoKeyboardScroll() {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object:  nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object:  nil)
            }
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            self.contentController!.view.alpha = 0
            self.contentController!.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (Bool) in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                self.contentController!.view.alpha = 1
                self.contentController!.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (Bool) in
        }
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification){
        if self.openKeyboard {
            return
        }
        let keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        self.popupScrollView?.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + keyboard!.height)
        self.openKeyboard = true
        UIView.animate(withDuration: 0.3, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.popupScrollView!.contentOffset = CGPoint(x: 0, y: keyboard!.height)
        }) { (Bool) in
                
        }
 
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        if self.openKeyboard {
            openKeyboard = false
            UIView.animate(withDuration: 0.3, delay: 0.2, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.popupScrollView!.contentOffset = CGPoint(x: 0, y: 0)
                self.popupScrollView?.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
                
            }) { (Bool) in
                
            }
        }
    }

    
    @objc func singleTapEvent(gesture:UITapGestureRecognizer){
        let location = gesture.location(in: self.view)
        if openKeyboard {
            if let delegate = self.contentController as? RPopupControllerDelegate {
                delegate.dismissKeyboard?()
            }
            return
        }
        if self.contentController!.view.frame.contains(location) {
        }else{
            if(self.cancelable){
                self.dismissPopup(nil)
            }
        }
    }
    
 
    func changeSize(_ height:CGFloat) {
        self.contentController!.view.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
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


class SimpleRPopupController : RPopupController{
    
    
    override func initController(_ height: CGFloat) {
        self.view.frame = UIScreen.main.bounds
        self.contentController?.view.rsWidth = SCREEN_WIDTH - POPUP_GAP_WIDTH
        (self.contentController as! SimplePopupController).resizeView()
        self.contentController!.view.center = self.view.center
        
        self.view.isOpaque = true
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        self.contentController!.view.alpha = 0
        self.contentController!.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.contentController!.view.layer.cornerRadius = 5

        self.popupScrollView = UIScrollView(frame: self.view.bounds)
        self.popupScrollView!.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.popupScrollView?.contentSize = self.view.frame.size
        self.popupScrollView!.addSubview(self.contentController!.view)
        self.view.addSubview(self.popupScrollView!)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(RPopupController.singleTapEvent(gesture:)))
        self.popupScrollView?.addGestureRecognizer(gesture)
        
        self.addChildViewController(self.contentController!)
    }
}

class SimplePopupController : UIViewController{
    
    @IBOutlet var pTitle:UILabel!
    @IBOutlet var pMessage:UILabel!
    @IBOutlet var confirmBtn:UIButton!
    @IBOutlet var cancelBtn:UIButton!
    @IBOutlet var bottom:UIView!
    var datas:[String:Any] = [String:Any]()
    var callback:((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resizeView()
    }
    
    @IBAction func cancelClick(_ sender:UIButton){
        (self.parent as! SimpleRPopupController).dismissPopup {
            if self.callback != nil {
                self.callback!("N")
            }
        }
    }
    @IBAction func okClick(_ sender:UIButton){
        (self.parent as! SimpleRPopupController).dismissPopup {
            if self.callback != nil {
                self.callback!("Y")
            }
        }
    }
    
    func resizeView() {
        pMessage.adJustWrapHeightSize()
        print(pMessage.frame)
        bottom.rsY = pMessage.rsEndY + 30
        bottom.superview?.rsHeight = bottom.rsEndY
        self.view.rsHeight = bottom.rsEndY
    }
    
    
}

