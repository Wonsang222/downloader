//
//  MGWKSubWebController.swift
//  wing
//
//  Created by 이동철 on 2018. 1. 11..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//
import WebKit
import UIKit

class MGWKSubWebController: BaseController, WKUIDelegate,WKNavigationDelegate  {
    
    var startUrl:String?
    var webViewSubContainer: UIView!
    var webView: WKWebView!
    
    // top navi
    var topNavigationView: UIView!
    // title label
    var webTitle: UILabel!
    // title url
    var webUrl: UILabel!
    
    var statusBarSize:CGFloat{
        get{
            return UIApplication.shared.statusBarFrame.height
        }
    }
    

    func loadedView(url: URLRequest, config: WKWebViewConfiguration) -> WKWebView {
        webViewSubContainer = UIView()
        topNavigationView = UIView()
        webTitle = UILabel()
        webUrl = UILabel()

        let dismissBtn = UIButton()
        
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        webViewSubContainer.bounds = self.view.bounds
        self.view.addSubview(webViewSubContainer)
        
        webViewSubContainer.center = self.view.center
        
        topNavigationView.frame = CGRect(x: 0.0, y:0, width: webViewSubContainer.bounds.width, height: 50 + statusBarSize)
        topNavigationView.backgroundColor = UIColor.white
        topNavigationView.addSubview(dismissBtn)
        dismissBtn.frame = CGRect(x: 0, y: statusBarSize, width: 50.0, height: 50.0)
        dismissBtn.setImage(UIImage(named: "ic_navi_back.png"), for: .normal)
        dismissBtn.onClick { (view) in
            self.dismiss(animated: true, completion: nil)
        }
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 15.0)
        webUrl.frame = CGRect(x: 50, y: 11+statusBarSize+15, width: topNavigationView.bounds.width, height: 13.0)
        webTitle.font = webTitle.font.withSize(14.0)
        webUrl.font = webUrl.font.withSize(11.0)
        webTitle.textColor = UIColor(hexString: "#333333")
        webUrl.textColor = UIColor(hexString: "#9494949")
        webTitle.textAlignment = .left
        webUrl.textAlignment = .left

//        if url.url?.host == "kauth.kakao.com" {
//            webTitle.text = "로그인"
//        } else if webView.title!.isEmpty {
//            webTitle.text = ""
//            webUrl.frame.origin.y = topNavigationView.center.y
//        } else {
//            webTitle.text = webView.title!
//        }
        webTitle.text = "읽어들이는중"
        webUrl.isHidden = true
        webTitle.frame = CGRect(x: 50, y: 10+statusBarSize, width: topNavigationView.bounds.width, height: 29.0)
        topNavigationView.backgroundColor = UIColor(hexString: "#f7f7f7")
        topNavigationView.addSubview(webTitle)
        topNavigationView.addSubview(webUrl)
        topNavigationView.addSubview(Tools.border1px(parent: topNavigationView, color: "#b9b9b9"))
        webView.addSubview(topNavigationView)
        webView.scrollView.contentInset = UIEdgeInsetsMake(topNavigationView.bounds.height - statusBarSize, 0.0, 0.0, 0.0)
        webView.bounds = webViewSubContainer.bounds
        webView.bounds = CGRect(x: 0.0, y: 0.0, width: webViewSubContainer.bounds.width, height: webViewSubContainer.bounds.height)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(url)
        webViewSubContainer?.addSubview(webView)
        
        return webView
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 29.0)
        webTitle.text = "읽어들이는중"
        webUrl.isHidden = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webTitle.frame = CGRect(x: 50, y: 11+statusBarSize, width: topNavigationView.bounds.width, height: 15.0)
        if webView.title == "" {
            webTitle.text = webView.url?.host
        }else{
            webTitle.text = webView.title
        }
        webUrl.text = webView.url?.host
        webUrl.isHidden = false
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        self.dismiss(animated: true, completion: nil)
    }
}
