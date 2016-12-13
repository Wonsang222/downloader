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
    	var url = NSURL (string: HttpMap.PUSH_PAGE + "?account_id=" + WInfo.accountId);
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
    }
    
    override func hybridEvent(value: [String : AnyObject]) {
        if value["func"] as! String == "movePage"{
            let moveUrl = value["param1"] as! String
            let mainController = self.navigationController?.viewControllers[0] as! WMainController
            mainController.movePage(moveUrl)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func webViewDidFinishLoad(webView: UIWebView) {
        if(self.webView.alpha == 0){
            UIView.animateWithDuration(0.6, animations: {
                self.webView.alpha = 1
            })
        }
    }
 
    
}

