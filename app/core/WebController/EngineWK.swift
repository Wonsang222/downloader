//
//  MGWKWebController.swift
//  wing
//
//  Created by WISA on 2018. 1. 8..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit


class EngineWK: WebEngine,WKUIDelegate,WKNavigationDelegate, UIScrollViewDelegate {
    private var _webView:WKWebView!
    var createWebView: WKWebView?
    
    override func loadRequest(_ request: URLRequest) {
        _webView.load(request)
    }
    
    override func loadEngine() {
        super.loadEngine()
        let config = WKWebViewConfiguration()
        config.processPool = WebEngine.gPool
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = .audio
        } else {
            // Fallback on earlier versions
        }
        
        
        _webView = WKWebView(frame: CGRect(x: self.controller.webViewContainer.bounds.origin.x,
                                           y: UIApplication.shared.statusBarFrame.height,
                                           width: self.controller.webViewContainer.bounds.size.width,
                                           height: self.controller.webViewContainer.bounds.size.height - Tools.safeArea() - UIApplication.shared.statusBarFrame.height - CGFloat(truncating: WInfo.naviHeight)),
                             configuration: config)
        
        _webView.uiDelegate = self
        _webView.navigationDelegate = self
        _webView.scrollView.delegate = self
        _webView.allowsBackForwardNavigationGestures = true
        self.controller.webViewContainer.addSubview(_webView)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        // 허용 접속시간 popup issue
        // 딜레이를 주는건 위험함! 다른방법있을까
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.controller.present(alert,animated:true, completion: nil)
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
        self.controller.present(alert,animated:true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "알림", message: message,
                                      preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            completionHandler()
        }))
        self.controller.present(alert,animated:true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: "알림", message: nil,
                                      preferredStyle: .alert);
        alert.addTextField { (textField) in
            textField.placeholder = "내용을 입력해주십시오."
        }
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(alert.textFields![0].text!)
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            // MARK: 취소할땐, nil 이나 빈 String을 넣어줘야할까? 아니면 그대로 넘겨줄까?
            // 일단은 nil 넘김 => javascript 와 똑같은 상황을 만들어주면 된다.
            completionHandler(nil)
        }))
        self.controller.present(alert, animated:true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.url == nil {
            return
        }
        
        if !(self.controller is NotiController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        self.createAccessCookie()
        
        WInfo.customAction(theme: WInfo.themeInfo["theme"] as! String, rootView: self.controller.view )
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        self.controller.progressView.alpha = 1.0
        self.controller.progressView.setProgress(0.0, animated: true)
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: { }, completion: { (bool) in
            self.controller.progressView.setProgress(Float(self._webView.estimatedProgress)+0.3, animated: true)
        })
        
        self.webDelegate?.webLoadedCommit(webView.url?.absoluteString)
        self.webDelegate?.webLoadedFinish(webView.url?.absoluteString)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.controller.progressView.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseIn, animations: { self.controller.progressView.alpha = 0 }, completion: { (bool: Bool) in
            self.controller.progressView.setProgress(0.0, animated: false)
        })
        
        if webView.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            self.runScript("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
        self.webDelegate?.webLoadedFinish(webView.url?.absoluteString)
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseIn, animations: { self.controller.progressView.alpha = 0 }, completion: { (bool: Bool) in
            self.controller.progressView.setProgress(0.0, animated: false)
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            preferences.preferredContentMode = .mobile
            if let urlString = navigationAction.request.url?.absoluteString {
                if urlString.hasPrefix("tel:") || urlString.hasPrefix("mailto:") {
                    UIApplication.shared.openURL(navigationAction.request.url!)
                    decisionHandler(.cancel, preferences)
                }else if !self.handleWing(urlString) {
                    decisionHandler(.cancel, preferences)
                }else if !self.handleEvent(urlString) {
                    decisionHandler(.cancel, preferences)
                }else if !self.handleApiEvent(urlString) {
                    decisionHandler(.cancel, preferences)
                }else if !self.handleItunes(urlString) {
                    decisionHandler(.cancel, preferences)
                }else if !self.handleSchema(urlString) {
                    decisionHandler(.cancel, preferences)
                }else{
                    decisionHandler(.allow, preferences)
                    return ;
                }
            }else{
                decisionHandler(.allow, preferences)
                return ;
            }
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
        
        self.controller.present(controller, animated: true, completion: nil)
        return re_webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        self.controller.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    
    override func runScript(_ script: String) {
        _webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    
    override var canGoBack: Bool {
        get{ return _webView.canGoBack }
    }
    override var canGoForward: Bool{
        get { return _webView.canGoForward }
    }
    override var currentURL: URL?{
        get{ return _webView.url }
    }
    override var webView: UIView{
        get{ return _webView }
    }
    override var scrollView: UIScrollView{
        get{ return _webView.scrollView }
    }
    override func goBack() {
        _webView.goBack()
    }
    override func goForward() {
        _webView.goForward()
    }
    override func reload(){
        _webView.reload()
    }
    override func clearHistory() {
        
    }
    
}


