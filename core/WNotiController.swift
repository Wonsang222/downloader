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
    	var url = URL (string: HttpMap.PUSH_PAGE + "?account_id=" + WInfo.accountId);
        if link != nil {
        	url = URL (string: link!);
        }
        let requestObj = URLRequest(url: url!);
        let contentView = self.view.subviews[0]
        let topView = self.view.subviews[1]
        contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIScreen.main.bounds.size.height)
        DispatchQueue.main.async{
            self.webView.scrollView.contentInset.top = topView.frame.size.height
            self.webView.scrollView.contentInset.bottom = 0
        }

        webView.loadRequest(requestObj);
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
 
    
}

