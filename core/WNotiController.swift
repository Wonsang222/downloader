//
//  WNotiController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WNotiController: BaseWebViewController,UIScrollViewDelegate{

	var link:String?
    
    var scrollBefore:CGFloat = 0.0
    var scrollDistance:CGFloat = 0.0
    var controlToggle = true
    let HIDE_THRESHOLD:CGFloat = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        webView.alpha = 0
        var url = URL (string: HttpMap.PUSH_PAGE + "?account_id=" + "WInfo.accountId");
//        var url = URL (string: "http://admin.magicapp.co.kr/notice/user_list_v2.php" + "?account_id=" + WInfo.accountId);
        if link != nil {
        	url = URL (string: link!);
        }
        var requestObj = URLRequest(url: url!);
        if let userId = WInfo.userInfo["userId"] as? String{
            requestObj.addValue(userId.encryptAES256(), forHTTPHeaderField: "MAGIC_USER_ID")
        }
        requestObj.addValue(UIDevice.current.identifierForVendor!.uuidString.encryptAES256(), forHTTPHeaderField: "MAGIC_DEVICE_ID")
        let contentView = self.view.subviews[0]
        let topView = self.view.subviews[1]
        contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.size.height)
        DispatchQueue.main.async{
            self.webView.scrollView.contentInset.top = topView.frame.size.height - 20
            self.webView.scrollView.contentInset.bottom = 0
            self.scrollBefore = self.webView.scrollView.contentOffset.y
        }

        webView.loadRequest(requestObj);
        webView.scrollView.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func hybridEvent(_ value: [String : AnyObject]) {
        if value["func"] as! String == "movePage"{
            
            let moveUrl = value["param1"] as! String
            let mainController = self.navigationController?.viewControllers[0] as! WMainController
            mainController.movePage(moveUrl)
            if self.navigationController != nil {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        if(self.webView.alpha == 0){
            UIView.animate(withDuration: 0.6, animations: {
                self.webView.alpha = 1
            })
        }
    }
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let moveY = scrollView.contentOffset.y < -self.topView!.frame.height ? -self.topView!.frame.height : scrollView.contentOffset.y
        print("\(scrollView.contentOffset.y) \(moveY)")
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
    
}

