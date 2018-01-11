//
//  MGWKSubWebController.swift
//  wing
//
//  Created by 이동철 on 2018. 1. 11..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//
import WebKit
import UIKit

class MGWKSubWebController: BaseController  {
    
    var startUrl:String?
    var webViewSubContainer: UIView?
    var webView: WKWebView!
    
    func loadedView(url:String){
        let config = WKWebViewConfiguration()
        let jsctrl = WKUserContentController()
        //        let Cont
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        self.view.addSubview(webView)
        webView.bounds = self.view.bounds
        webView.center = self.view.center
        
        webView.uiDelegate = self as? WKUIDelegate
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(URLRequest(url: URL(string: url)!))
        webViewSubContainer?.addSubview(webView)
        
        
    }
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        if startUrl != nil {
    //            self.webView.load(URLRequest(url :URL(string: startUrl!)!))
    //        }
    //    }
}
