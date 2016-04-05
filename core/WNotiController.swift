//
//  WNotiController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WNotiController: UIViewController {


	@IBOutlet weak let webview: UIWebView!
	var link?:String


    override func viewDidLoad() {
        super.viewDidLoad()
    	var url = NSURL (string: HttpMap.PUSH_PAGE);
        if link != nil {
        	url = link!
        }
        let requestObj = NSURLRequest(URL: url);
        webView.scrollView.contentInset.top = 0
        webView.loadRequest(requestObj);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

