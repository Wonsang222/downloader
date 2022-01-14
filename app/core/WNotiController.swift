//
//  WNotiController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WNotiController: BaseWebController,UIScrollViewDelegate,WebControlDelegate{
    
    var link:String?
    var type:String?
    var seq:String!
    var scrollBefore:CGFloat = 0.0
    var scrollDistance:CGFloat = 0.0
    var controlToggle = true
    let HIDE_THRESHOLD:CGFloat = 20.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.engine.webDelegate = self
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        self.engine.webView.alpha = 0
        type = type != nil ? type : "all"
        let url = URL (string: HttpMap.PUSH_PAGE + "?account_id=" + WInfo.accountId + "&view=" + type!)
        var requestObj = URLRequest(url: url!);
        if let userId = WInfo.userInfo["userId"] as? String{
            requestObj.addValue(userId.encryptAES256(), forHTTPHeaderField: "MAGIC_USER_ID")
        }
        requestObj.addValue(WInfo.deviceId.encryptAES256(), forHTTPHeaderField: "MAGIC_DEVICE_ID")
        if seq != nil {
            requestObj.addValue(seq, forHTTPHeaderField: "MAGIC_NOTIFI_SEQ") // push 클릭수 수집용도 (푸시 idx 값)
        }        
        let contentView = self.view.subviews[0]
        let topView = self.view.subviews[1]
        contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.size.height)
        self.engine.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - Tools.safeArea())
        DispatchQueue.main.async{
            self.engine.scrollView.contentInset.top = topView.frame.size.height
            self.engine.scrollView.contentInset.bottom = 0
            self.scrollBefore = self.engine.scrollView.contentOffset.y
        }
        if #available(iOS 11.0, *) {
            self.engine.scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.engine.scrollView.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.engine.loadRequest(requestObj)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let moveY = scrollView.contentOffset.y < -self.topView!.frame.height ? -self.topView!.frame.height : scrollView.contentOffset.y
        let dy = moveY - self.scrollBefore
        self.scrollBefore = moveY
        if scrollDistance > HIDE_THRESHOLD && controlToggle {
            UIView.animate(withDuration: 0.4, animations: {
                self.topView?.transform.ty = -self.topView!.frame.height
            })
            self.controlToggle = false
            self.scrollDistance = 0
        }else if scrollDistance < -HIDE_THRESHOLD && !controlToggle{
            UIView.animate(withDuration: 0.4, animations: {
                self.topView?.transform.ty = 0
            })
            self.controlToggle = true
            self.scrollDistance = 0
        }
        if controlToggle && dy>0 || (!controlToggle && dy<0){
            self.scrollDistance += dy
        }
    }
    
    /* WebControl Delegate */
    func webLoadedFinish(_ urlString:String?){
        seq = ""
        if(self.engine.webView.alpha == 0){
            UIView.animate(withDuration: 0.6, animations: {
                self.engine.webView.alpha = 1
            })
        }
    }
    func webLoadedCommit(_ urlString:String?){
    }
    func hybridEvent(_ value: [String:AnyObject]){
        if value["func"] as! String == "movePage"{
            let moveUrl = value["param1"] as! String
            let mainController = self.navigationController?.viewControllers[0] as! WMainController
            mainController.movePage(moveUrl)
            if self.navigationController != nil {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
}

