//
//  WNotiController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WNotiController: UIViewController,UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
	var link:String?


    override func viewDidLoad() {
        super.viewDidLoad()
    	var url = NSURL (string: HttpMap.PUSH_PAGE + "?pack_name" + AppProp.appId);
        if link != nil {
        	url = NSURL (string: link!);
        }
        let requestObj = NSURLRequest(URL: url!);
        webView.scrollView.contentInset.top = 0
        webView.loadRequest(requestObj);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}

