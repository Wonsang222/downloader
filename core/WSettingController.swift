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
    
    let pattern: String = "111000"
    var patternPos: Int = 0
    
    @IBOutlet weak var curVersion: UILabel!
    @IBOutlet weak var newVersion: UILabel!
    @IBOutlet weak var orderSwitch: UISwitch!
    @IBOutlet weak var eventSwitch: UISwitch!
    
    var appUpdateUrl:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        curVersion.text = AppProp.appVersion
        newVersion.text = WInfo.cacheVersion
        
        RSHttp(controller:self).req(
            ApiFormApp().ap("mode","get_push_agree_tot").ap("pack_name", AppProp.appId),
            successCb: { (resource) -> Void in
                let json = resource.body()["result"] as! String
                self.eventSwitch.setOn(json == "Y" ? true : false, animated: false)
        }
        )
        
        RSHttp(controller: self, showingPopup: false).req(
            ResourceVER().ap("mode", "version_chk").ap("bundleId", AppProp.appId).ap("country", "KR")
            , successCb: { (resource) -> (Void) in
                let mode = resource.params["mode"]!
                var new_version_str: String = ""
                
                if mode == "version_chk" {
                    if let app_info = resource.body()["results"] as? [[String: AnyObject]] {
                        if app_info.count > 0 {
                            new_version_str = app_info[0]["version"] as! String
                            self.appUpdateUrl = app_info[0]["trackViewUrl"] as? String
                        } else {
                            // 배포전 테스트플라잇 예외, 로컬버전 삽입
                            new_version_str = AppProp.appVersion
                            self.appUpdateUrl = ""
                        }
                    }
                    
                    self.newVersion.text = new_version_str
                    WInfo.cacheVersion = new_version_str
                }
        })
        self.eventSwitch.addTarget(self, action:#selector(WSettingController.switchChange(_:)) , for: UIControlEvents.touchUpInside)
        
        let one_gesture = UITapGestureRecognizer(target: self, action: #selector(self.push_test))
        let zero_gesture = UITapGestureRecognizer(target: self, action: #selector(self.push_test))
        one_gesture.numberOfTapsRequired = 1;
        zero_gesture.numberOfTapsRequired = 1;
        self.curVersion.superview!.tag = 100
        self.newVersion.superview!.tag = 101
        self.curVersion.superview!.addGestureRecognizer(one_gesture)
        self.newVersion.superview!.addGestureRecognizer(zero_gesture)
    }
    
    @objc func push_test(gesture: UITapGestureRecognizer){
        let num = gesture.view?.tag
        let str_num: String
        if num == 100 { str_num = "1" }
        else { str_num = "0" }
        
        if pattern.count - 1 < patternPos {
            patternPos = 0
            return
        }
        
        if String(pattern[patternPos]) == str_num {
            patternPos = patternPos + 1
        } else {
            patternPos = 0
        }
        
        if patternPos == 6 {
            patternPos = 0
            let alert = UIAlertController(title: AppProp.appName, message: "테스트 푸시를 발송하시겠습니까?" ,preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.default) { (action) in
                RSHttp(controller: self).req(
                    ResourceBuilderPushTest()
                        .ap("account_id", WInfo.accountId)
                        .ap("ios_token" , WInfo.deviceToken)
                        .ap("ios_pack_name", AppProp.appId)
                    , successCb: { (resource) -> (Void) in
                }
                )
            })
            alert.addAction(UIAlertAction(title: "취소" , style: UIAlertActionStyle.cancel, handler:nil))
            
            self.present(alert,animated:true, completion: nil)
        }
    }
    
    
    @objc func switchChange(_ sender:UISwitch){
        let event = eventSwitch.isOn ? "Y" : "N"
        self.setMarketingAgree(yn:event,{})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func doUpdateBtn(_ sender:UIButton){
        if Tools.compareVersion(newVersion.text!, curVersion.text!) {
            UIApplication.shared.openURL(URL(string:self.appUpdateUrl!)!)
        }else{
            self.view.makeToast("최신버전입니다.")
        }
        
    }
}

