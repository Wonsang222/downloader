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
    
    func loadedView(url: URLRequest, config: WKWebViewConfiguration) -> WKWebView {
        webViewSubContainer = UIView()
        topNavigationView = UIView()
        webTitle = UILabel()
        webUrl = UILabel()
        let dismissBtn = UIButton()
        
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        
        if #available(iOS 9.0, *) {
            //            webView.allowsLinkPreview = true
        }
        self.view.bounds = UIScreen.main.bounds
        webViewSubContainer.bounds = self.view.bounds
        self.view.addSubview(webViewSubContainer)
        
        webViewSubContainer.center = self.view.center
        
        topNavigationView.frame = CGRect(x: 0.0, y: UIApplication.shared.statusBarFrame.height - 20, width: webViewSubContainer.bounds.width, height: 80)
        topNavigationView.backgroundColor = UIColor.white

        topNavigationView.addSubview(dismissBtn)
        dismissBtn.frame = CGRect(x: 0.0, y: 5.0, width: 80.0, height: 80.0)
        dismissBtn.contentEdgeInsets.top = 10.0
        dismissBtn.setImage(UIImage(named: "ic_navi_back.png"), for: .normal)
        dismissBtn.onClick { (view) in
            self.dismiss(animated: true, completion: nil)
        }
        webTitle.frame = CGRect(x: 0.0, y: 30.0, width: topNavigationView.bounds.width, height: 20.0)
        webUrl.frame = CGRect(x: 0.0, y: 50.0, width: topNavigationView.bounds.width, height: 20.0)
        webTitle.font.withSize(12.0)
        webUrl.font.withSize(10.0)
        webTitle.textColor = UIColor(hexString: "#333333")

        webUrl.textColor = UIColor(hexString: "#888888")
        webTitle.textAlignment = .center
        webUrl.textAlignment = .center
        
        if url.url?.host == "kauth.kakao.com" {
            webTitle.text = "로그인"
        } else if webView.title!.isEmpty {
            webTitle.text = "이름없음"
        } else {
            webTitle.text = webView.title!
        }
        
        webUrl.text = url.url?.host// 예시
        
        topNavigationView.addSubview(webTitle)
        topNavigationView.addSubview(webUrl)
        
        webView.addSubview(topNavigationView)
        webView.scrollView.contentInset = UIEdgeInsetsMake(topNavigationView.bounds.height - 20, 0.0, 0.0, 0.0)
        webView.bounds = webViewSubContainer.bounds
        webView.bounds = CGRect(x: 0.0, y: 0.0, width: webViewSubContainer.bounds.width, height: webViewSubContainer.bounds.height)
        print("webView bounds: \(webView.bounds.origin.x) \(webView.bounds.origin.y)")
        
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
