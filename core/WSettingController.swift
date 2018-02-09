//
//  WSettingController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WSettingController: BaseController {

    var tapCount = 0
    
    @IBOutlet weak var curVersion: UILabel!
    @IBOutlet weak var newVersion: UILabel!
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var eventSwitch: UISwitch!
    
    var appUpdateUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        curVersion.text = AppProp.appVersion
        RSHttp(controller:self).req(
                ApiFormApp().ap("mode","get_agree").ap("pack_name", AppProp.appId),
                ApiFormApp().ap("mode","version_chk").ap("pack_name", AppProp.appId)
            ,
            successCb: { (resource) -> Void in
                let mode = resource.params["mode"]!
                if mode == "version_chk" {
                    let version = resource.body()["version"] as! String
                    self.appUpdateUrl = resource.body()["app_url"] as? String
                    self.newVersion.text = version
                }else {
                    let json = resource.body()["result"] as! [String:AnyObject]
                    let order_push_agree = json["order_push_agree"] as! String
                    let notice_push_agree = json["notice_push_agree"] as! String
                    
                    self.orderSwitch.setOn(order_push_agree == "Y" ? true : false, animated: false)
                    self.eventSwitch.setOn(notice_push_agree == "Y" ? true : false, animated: false)
                }
            }
        )
        
        self.orderSwitch.addTarget(self, action:#selector(WSettingController.switchChange(_:)) , for: UIControlEvents.touchUpInside)
        self.eventSwitch.addTarget(self, action:#selector(WSettingController.switchChange(_:)) , for: UIControlEvents.touchUpInside)

        
        
        let bundle_id = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
        if bundle_id.hasSuffix(".lh") || bundle_id.hasSuffix(".adhoc"){
            let gesture = UITapGestureRecognizer(target: self, action: #selector(WSettingController.push_test))
            gesture.numberOfTapsRequired = 1;
            self.newVersion.superview!.addGestureRecognizer(gesture)
        }
        
        
        
    }
    
    @objc func push_test(){
        tapCount = tapCount + 1
        if tapCount == 10 {
            tapCount = 0;
            let bundle_id = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String

            RSHttp(controller: self).req(
                
                
            )
            RSHttp(controller: self).req(
                ResourceBuilderPushTest().ap("token",WInfo.deviceToken).ap("package",bundle_id)
                , successCb: { (resource) -> (Void) in
                    self.view.makeToast("테스트 푸쉬 발송")
                UIApplication.shared.openURL(URL(string: "http://naver.com")!)
            })

        }
    }

    
    @objc func switchChange(_ sender:UISwitch){
        let event = eventSwitch.isOn ? "Y" : "N"
        let order = orderSwitch.isOn ? "Y" : "N"

        RSHttp(controller:self).req(
            ApiFormApp().ap("mode","set_agree")
                .ap("pack_name", AppProp.appId)
                .ap("notice_push_agree", event)
                .ap("order_push_agree", order)
            ,
            successCb: { (resource) -> Void in
            }
        )
        
//        if eventSwitch.on && !WInfo.agreeMarketing {
//            let dialog = createMarketingDialog({ (UIAlertAction) in
//                RSHttp(controller:self).req(
//                    [ApiFormApp().ap("mode","set_marketing_agree").ap("pack_name",AppProp.appId).ap("marketing_agree","Y")],
//                    successCb: { (resource) -> Void in
//                        WInfo.firstProcess = true
//                        WInfo.agreeMarketing = true
//                        self.eventSwitch.on = true
//                        
//                        RSHttp(controller:self).req(
//                            ApiFormApp().ap("mode","set_agree")
//                                .ap("pack_name", AppProp.appId)
//                                .ap("notice_push_agree", "Y")
//                                .ap("order_push_agree", order)
//                            ,
//                            successCb: { (resource) -> Void in
//                            }
//                        )
//                        
//                    },errorCb:{ (errorCode,resource) -> Void in
//                        self.eventSwitch.on = false
//                    }
//                )
//                
//            }) { (UIAlertAction) in
//                self.eventSwitch.on = false
//                RSHttp(controller:self).req(
//                    ApiFormApp().ap("mode","set_agree")
//                        .ap("pack_name", AppProp.appId)
//                        .ap("notice_push_agree", "N")
//                        .ap("order_push_agree", order)
//                    ,
//                    successCb: { (resource) -> Void in
//                    }
//                )
//                
//            }
//            self.presentViewController(dialog, animated: true, completion: nil)
//        }else{
//           
//        }
        
        
        

    }

    
    func reqSetAgree(_ yn:String,orderyn:String){
        
        RSHttp(controller:self).req(
            ApiFormApp().ap("mode","set_agree")
                .ap("pack_name", AppProp.appId)
                .ap("notice_push_agree", yn)
                .ap("order_push_agree", orderyn)
            ,
            successCb: { (resource) -> Void in
            }
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doUpdateBtn(_ sender:UIButton){
        
        if Int(newVersion.text!.replace(".", withString: "")) > Int(curVersion.text!.replace(".", withString: "")) {
            UIApplication.shared.openURL(URL(string:self.appUpdateUrl!)!)
        }else{
            self.view.makeToast("최신버전입니다.")
        }
        
    }
}

