//
//  MGWKWebController.swift
//  wing
//
//  Created by WISA on 2018. 1. 8..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit


class MGWKWebController: WebController,WKUIDelegate,WKNavigationDelegate {
    var webView:WKWebView!
    
    
    
    override var webViewCanGoBack: Bool {
        get{
            return self.webView.canGoBack
        }
    }
    
    override var webViewCanGoForward: Bool{
        get {
            return self.webView.canGoForward
        }
    }
    override var currentURL: URL?{
        get{
            return self.webView.url
        }
    }
    override func loadRequest(_ request: URLRequest) {
        self.webView.load(request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        let jsctrl = WKUserContentController()
        
        
        webView = WKWebView(frame: webViewContainer.bounds, configuration: config)
        if #available(iOS 9.0, *) {
//            webView.allowsLinkPreview = true
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webViewContainer.addSubview(webView)
    }
    
    func reloadPage(){
        self.webView.reload()
        
    }
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

//    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alert,animated:true, completion: nil)

    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "알림", message: message,
                                      preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alert,animated:true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.url == nil {
            return
        }
        if !(self is NotiController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        self.createAccessCookie()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.webLoadedCommit(webView.url?.absoluteString)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if webView.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            self.runScript("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
        self.webLoadedFinish(webView.url?.absoluteString)
        print("FINISH")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url?.absoluteString)
        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.hasPrefix("tel:") || urlString.hasPrefix("mailto:") {
                UIApplication.shared.openURL(navigationAction.request.url!)
                decisionHandler(.cancel)
            }else if !self.handleWing(urlString) {
                decisionHandler(.cancel)
            }else if !self.handleWing(urlString) {
                decisionHandler(.cancel)
            }else if !self.handleEvent(urlString) {
                decisionHandler(.cancel)
            }else if !self.handleApiEvent(urlString) {
                decisionHandler(.cancel)
            }else if !self.handleItunes(urlString) {
                decisionHandler(.cancel)
            }else if !self.handleSchema(urlString) {
                decisionHandler(.cancel)
            }else{
                decisionHandler(.allow)
            }
        }else{
            decisionHandler(.allow)
        }
    }
//    func webViewDidStartLoad(_ webView: UIWebView){
//        if webView.request == nil {
//            return
//        }
//        if !(self is NotiController) {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        }
//        self.createAccessCookie()
//    }
    
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        if webView.request!.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
//            self.runScript("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
//        }
//    }
    
//    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler:
//        (WKNavigationActionPolicy) -> Void) {
//        if navigationAction.request.URL!.absoluteString.hasPrefix("tel:") || navigationAction.request.URL!.absoluteString.hasPrefix("mailto:"){
//            UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
//            decisionHandler(.Cancel)
//            return
//        }
//        decisionHandler(.Allow)
//    }
    
    
    
    
    /*
     func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
     if navigationAction.request.URL != nil {
     if !navigationAction.request.URL!.absoluteString.isEmpty {
     
     if navigationAction.request.URL!.absoluteString.hasPrefix("https://smpay.kcp.co.kr") {
     return nil
     }else{
     //                    let subWebView = WKWebView(frame: self.webView.frame, configuration: configuration)
     //                    subWebView.loadRequest(navigationAction.request)
     UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
     //                    self.webViewContainer.addSubview(subWebView)
     //                    return subWebView
     }
     
     }
     }
     return nil;
     }
     
     
     func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
     progressView.setProgress(Float(webView.estimatedProgress), animated: true)
     //        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
     //        webView.evaluateJavaScript(javascript, completionHandler: nil)
     }
     
     func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
     print("error \(error)")
     }
     
     func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
     progressView.setProgress(1, animated: true)
     UIView.animateWithDuration(0.3, delay: 1, options: .CurveEaseInOut, animations: { self.progressView.alpha = 0 }, completion: nil)
     }
     
   
     
     /*
     Smshinhanansimclick      // 스마트 신한 URL 스키마
     shinhan-sr-ansimclick     // 신마트 신한앱 URL 스키마
     smhyundaiansimclick      // 현대카드 URL 스키마
     nonghyupcardansimclick   // NH 안심클릭 URL 스키마
     paypin                    // PAYPIN URL 스키마
     ispmobile                 // ISPMOBILE URL 스키마
     */
     
     func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler:
     (WKNavigationActionPolicy) -> Void) {
     if navigationAction.request.URL!.absoluteString.hasPrefix("tel:") || navigationAction.request.URL!.absoluteString.hasPrefix("mailto:"){
     UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
     decisionHandler(.Cancel)
     return
     }
     decisionHandler(.Allow)
     }
     
     func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
     }
     
     */
    
   
    override func runScript(_ script: String) {
        self.webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    
}
