//
//  PermissionController.swift
//  wing
//
//  Created by WISA on 2017. 11. 14..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class PermissionController: BaseController{

    var callback:(()->Void)?
    @IBOutlet var gpsGuide:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gpsGuide.text = AppProp.gpsUseMessage
    }
    @IBAction func confirm() {
        WInfo.confirmPermission = true
        hide()
    }
    
    
    func show(parent:UIViewController , callback: @escaping ()->Void){
        self.view.frame = parent.view.bounds
        parent.view.addSubview(self.view)
        self.view.alpha = 0
        self.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (finish) in
        }
        self.callback = callback
    }
    func hide(){
        UIView.setAnimationCurve(UIViewAnimationCurve.easeOut)
        UIView.animate(withDuration: 0.6, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.view.alpha = 0
        }) { (finish) in
            self.view.removeFromSuperview()
            self.callback?()
        }
    }
}
