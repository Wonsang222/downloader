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
    var createWebView: WKWebView?
    
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
        print("진입1")
        self.webView.load(request)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("진입2")
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
        print("진입3")
        self.webView.reload()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        // 허용 접속시간 popup issue
        // 딜레이를 주는건 위험함! 다른방법있을까
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.present(alert,animated:true, completion: nil)
        }
    
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

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

        let alert = UIAlertController(title: "알림", message: nil,
                                      preferredStyle: .alert);
        alert.addTextField { (textField) in
            textField.placeholder = "내용을 입력해주십시오."
            print("\(String(describing: textField.text))")
        }
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(alert.textFields![0].text!)
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            // MARK: 취소할땐, nil 이나 빈 String을 넣어줘야할까? 아니면 그대로 넘겨줄까?
            // 일단은 nil 넘김 => javascript 와 똑같은 상황을 만들어주면 된다.
            completionHandler(nil)
        }))
        self.present(alert, animated:true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("gdgd: \(webView.url)")
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
        self.progressView.alpha = 1.0
        self.progressView.setProgress(0.0, animated: true)
        UIView.animate(withDuration: 1, delay: 1.3, options: .curveEaseIn, animations: { }, completion: { (bool) in
            self.progressView.setProgress(Float(self.webView.estimatedProgress)+0.3, animated: true)
        })
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.progressView.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseIn, animations: { self.progressView.alpha = 0 }, completion: { (bool: Bool) in
            self.progressView.setProgress(0.0, animated: false)
        })
        
        if webView.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            self.runScript("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
        
        self.webLoadedFinish(webView.url?.absoluteString)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {

        UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseIn, animations: { self.progressView.alpha = 0 }, completion: { (bool: Bool) in
            self.progressView.setProgress(0.0, animated: false)
        })
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.hasPrefix("tel:") || urlString.hasPrefix("mailto:") {
                UIApplication.shared.openURL(navigationAction.request.url!)
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
                return ;
            }
        }else{
            decisionHandler(.allow)
            return ;
        }
        
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let controller = MGWKSubWebController()
        let re_webView = controller.loadedView(url: (navigationAction.request), config: configuration)
        
        self.present(controller, animated: true, completion: nil)
        
        return re_webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("cancel gogo")
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("cancel gogo2")
    }
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    
    
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
