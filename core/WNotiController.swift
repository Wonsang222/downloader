//
//  WNotiController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WNotiController: BaseWebViewController{

	var link:String?


    override func viewDidLoad() {
        super.viewDidLoad()
        webView.alpha = 0
    	var url = NSURL (string: HttpMap.PUSH_PAGE + "?pack_name=" + AppProp.appId);
        if link != nil {
        	url = NSURL (string: link!);
        }
        let requestObj = NSURLRequest(URL: url!);
        let contentView = self.view.subviews[0]
        let topView = self.view.subviews[1]
        contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), UIScreen.mainScreen().bounds.size.height)
        dispatch_async(dispatch_get_main_queue()){
            self.webView.scrollView.contentInset.top = topView.frame.size.height
            self.webView.scrollView.contentInset.bottom = 0
        }

        webView.loadRequest(requestObj);
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        
//        let deviceId = UILabel(frame: CGRectMake(0,400,320,100))
//        deviceId.numberOfLines = 10
//        deviceId.text = WInfo.deviceToken
//        deviceId.textColor = UIColor.blackColor()
//        self.view.addSubview(deviceId)
    }
    
    
    override func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let jsonString = message.body as! String
        do{
            let dic = try NSJSONSerialization.JSONObjectWithData(
            jsonString.dataUsingEncoding(NSUTF8StringEncoding)!,
            options: NSJSONReadingOptions()) as! [String:AnyObject]
            if dic["func"] as! String == "movePage"{
                let moveUrl = dic["param1"] as! String
                let mainController = self.navigationController?.viewControllers[0] as! WMainController
                mainController.movePage(moveUrl)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }catch{
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        super.webView(webView, didFinishNavigation: navigation)
        if(self.webView.alpha == 0){
            UIView.animateWithDuration(0.6, animations: {
                self.webView.alpha = 1
            })
        }
    }
    
    
    
    
}

