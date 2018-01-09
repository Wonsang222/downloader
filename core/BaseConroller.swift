//
//  BaseController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class BaseController: UIViewController {

	@IBOutlet weak var topView: UIView?
    @IBOutlet var topTitle:UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tracker = (UIApplication.shared.delegate as! WAppDelegate).tracker {
            if let title = self.title {
                if !title.isEmpty{
                    tracker.set(kGAIScreenName, value: self.title!)
                    let builder = GAIDictionaryBuilder.createScreenView()
                    tracker.send(builder!.build() as [NSObject:AnyObject])
                }
            }
        }
        if let title = self.title {
            if !title.isEmpty{
                WisaTracker().page(self.title!)
            }
        }
        
        
    }
    
    
    @IBAction func doBack(_ sender:AnyObject){
        if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    
    func createMarketingDialog(_ url:String ,resp:@escaping ((String) -> Void)) -> RPopupController {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "push_agree_popup") as! MarketingPopupController
        controller.url = url
        let bizPoup = RPopupController(controlller: controller,height: 0)
        bizPoup.cancelable = false
        bizPoup.resp = resp
        return bizPoup
    }
    
    
    func createMarketingAlert(_ agree:@escaping ((UIAlertAction) -> Void),disagree:@escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: "알림", message: "해당기기로 이벤트, 상품할인 등의 정보를\n전송하려고 합니다." ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "동의" , style: UIAlertActionStyle.default, handler:agree))
        alert.addAction(UIAlertAction(title: "미동의" , style: UIAlertActionStyle.default, handler:disagree))
        return alert
    }
    func createMarketingAlertV2(resp:@escaping ((String) -> Void)) -> RPopupController {
        let popupView = self.storyboard!.instantiateViewController(withIdentifier: "popup") as! SimplePopupController
        let popup = SimpleRPopupController(controlller: popupView)
        popupView.pTitle.text = "알림"
        popupView.pMessage.text = "해당기기로 이벤트, 상품할인 등의 정보를\n전송하려고 합니다."
        popupView.confirmBtn.setTitle("동의", for: .normal)
        popupView.cancelBtn.setTitle("미동의", for: .normal)
        popupView.callback = resp
        popup.cancelable = false
        popup.delegate = self
        return popup
    }
    
}



