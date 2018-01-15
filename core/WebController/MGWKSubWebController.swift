//
//  MGWKSubWebController.swift
//  wing
//
//  Created by 이동철 on 2018. 1. 11..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//
import WebKit
import UIKit

class MGWKSubWebController: BaseController, WKUIDelegate  {
    
    var startUrl:String?
    var webViewSubContainer: UIView!
    var webView: WKWebView!
    
    // top navi
    var topNavigationView: UIView!
    
    
    func loadedView(url: URLRequest, config: WKWebViewConfiguration) -> WKWebView {
        webViewSubContainer = UIView()
        topNavigationView = UIView()
//        let config = WKWebViewConfiguration()
        let jsctrl = WKUserContentController()
        let dismissBtn = UIButton()
//        if webViewSubContainer == nil {
//            webViewSubContainer = UIView()
//
//        }
        
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        //        let Cont
        
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        webViewSubContainer.bounds = self.view.bounds
        self.view.addSubview(webViewSubContainer)
        
        
        webViewSubContainer.center = self.view.center
//        topNavigationView.center = webViewSubContainer.center
        
        
        topNavigationView.contentMode = .topLeft
        topNavigationView.frame = CGRect(x: 0, y: 0, width: webViewSubContainer.bounds.width, height: 50.0)
        topNavigationView.backgroundColor = UIColor.white
        webViewSubContainer.addSubview(topNavigationView)
        topNavigationView.addSubview(dismissBtn)
        dismissBtn.bounds = CGRect(x: 20.0, y: topNavigationView.center.y, width: webViewSubContainer.bounds.width, height: topNavigationView.bounds.height)
        dismissBtn.setTitle("backbutn", for: .normal)
        dismissBtn.onClick { (view) in
            self.dismiss(animated: true, completion: nil)
        }
        
        webView.bounds = webViewSubContainer.bounds
//        webView.center = webViewSubContainer.center
//        webView.bounds.changeY(webViewSubContainer.bounds.midY - 50.0)
//
//        print("webview dd : \(webView.bounds.midX)")
//        print("webview dd : \(webView.bounds.midY)")
        webView.uiDelegate = self as? WKUIDelegate
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(url)
        webViewSubContainer?.addSubview(webView)
        
        return webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("it is ?? ")
        
        self.dismiss(animated: true, completion: nil)
    }
}
