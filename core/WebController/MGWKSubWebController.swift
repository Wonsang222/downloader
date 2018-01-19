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
    // title label
    var webTitle: UILabel!
    // title url
    var webUrl: UILabel!
    // status bar
    var statusBar: UIView!
    // bottom border
    var bottomBorder: UIView!
    
    func loadedView(url: URLRequest, config: WKWebViewConfiguration) -> WKWebView {
        webViewSubContainer = UIView()
        topNavigationView = UIView()
        webTitle = UILabel()
        webUrl = UILabel()
        statusBar = UIView()
        bottomBorder = UIView()
        
        let dismissBtn: UIButton = UIButton()
        let locationbar_height: CGFloat = 50.0
        
        print("statusbar : \(UIApplication.shared.statusBarFrame.height)")
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        
        statusBar.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: UIApplication.shared.statusBarFrame.height)
        statusBar.backgroundColor = .white
        webViewSubContainer.backgroundColor = .red
        webViewSubContainer.frame = CGRect(x: 0.0, y: UIApplication.shared.statusBarFrame.height, width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.view.addSubview(statusBar)
        self.view.addSubview(webViewSubContainer)
        
//        webViewSubContainer.center = self.view.center
        
        topNavigationView.frame = CGRect(x: 0.0, y:0.0, width: webViewSubContainer.bounds.width, height: locationbar_height)
        topNavigationView.backgroundColor = UIColor.white
        
        bottomBorder.frame = CGRect(x: 0, y: locationbar_height, width: webViewSubContainer.bounds.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor(hexString: "#c9c9c9")
        
        
        topNavigationView.addSubview(dismissBtn)
        topNavigationView.addSubview(bottomBorder)
        dismissBtn.frame = CGRect(x: 5.0, y: 0.0, width: topNavigationView.bounds.height, height: topNavigationView.bounds.height)
        
        dismissBtn.setImage(UIImage(named: "ic_navi_back.png"), for: .normal)
        dismissBtn.onClick { (view) in
            self.dismiss(animated: true, completion: nil)
        }
//        dismissBtn.backgroundColor = .red
//        webTitle.backgroundColor = .blue
//        webTitle.backgroundColor = .green
        webTitle.frame = CGRect(x: 0.0, y: topNavigationView.center.y - 18, width: topNavigationView.bounds.width, height: 20.0)
        webUrl.frame = CGRect(x: 0.0, y: topNavigationView.center.y - 3, width: topNavigationView.bounds.width, height: 20.0)
        
        webTitle.font = webTitle.font.withSize(12.0)
        webUrl.font = webUrl.font.withSize(10.0)
        
        webTitle.textColor = UIColor(hexString: "#333333")
        webUrl.textColor = UIColor(hexString: "#888888")
        
        webTitle.textAlignment = .center
        webUrl.textAlignment = .center
        
        if url.url?.host == "kauth.kakao.com" {
            webTitle.text = "로그인"
        } else if webView.title!.isEmpty {
            webTitle.text = ""
            webUrl.font = webUrl.font.withSize(12.0)
            webUrl.frame.origin.y = topNavigationView.center.y - 10
        } else {
            webTitle.text = webView.title!
        }
        
        webUrl.text = url.url?.host
        
        topNavigationView.addSubview(webTitle)
        topNavigationView.addSubview(webUrl)
        
        webView.addSubview(topNavigationView)
        webView.scrollView.contentInset = UIEdgeInsetsMake(topNavigationView.bounds.height, 0.0, 0.0, 0.0)
        webView.frame = webViewSubContainer.bounds
        webView.frame = CGRect(x: 0.0, y: 0.0, width: webViewSubContainer.bounds.width, height: webViewSubContainer.bounds.height)
        webView.uiDelegate = self
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
