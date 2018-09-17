//
//  MGUIWebController.swift
//  wing
//
//  Created by WISA on 2018. 1. 8..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit


class EngineUI: WebEngine,UIWebViewDelegate{
    private var _webView:UIWebView!
    private var _tmpUrl: String!
    
    override func loadRequest(_ request: URLRequest) {
        _webView.loadRequest(request)
    }
    
    override func loadEngine() {
        super.loadEngine()
        _webView = UIWebView(frame: CGRect(x: self.controller.webViewContainer.bounds.origin.x,
                                           y: UIApplication.shared.statusBarFrame.height / 2,
                                           width: self.controller.webViewContainer.bounds.size.width,
                                           height: self.controller.webViewContainer.bounds.size.height - UIApplication.shared.statusBarFrame.height / 2 - CGFloat(truncating: WInfo.naviHeight))
        )
        _webView.allowsInlineMediaPlayback = true
        
        if #available(iOS 9, *) {
            _webView.allowsLinkPreview = false
            _webView.allowsPictureInPictureMediaPlayback = true
        }
        
        _webView.keyboardDisplayRequiresUserAction = false
        _webView.delegate = self
        _webView.autoresizingMask = [UIViewAutoresizing.flexibleHeight,UIViewAutoresizing.flexibleWidth]
        _webView.scalesPageToFit = true
        
        // cache clear
//        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        
        self.controller.webViewContainer.addSubview(webView)
    }

    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let urlString = request.url?.absoluteString {
            if !self.handleWing(urlString) {
                return false;
            }
            if !self.handleEvent(urlString) {
                return false;
            }
            if !self.handleApiEvent(urlString) {
                return false;
            }
            if !self.handleItunes(urlString) {
                return false;
            }
            if !self.handleSchema(urlString) {
                return false;
            }
//            if let req_host = request.url?.host {
//                if WInfo.appUrl.range(of: req_host) == nil && navigationType == .linkClicked {
//                    UIApplication.shared.openURL(request.url!);
//                    return false;
//                }
//            }
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        if webView.request == nil {
            return
        }
       
        
        if !(self.controller is NotiController) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        
//        if self._tmpUrl == webView.request?.url?.absoluteString {
//            print("dong3 start??")
//            return ;
//        } else {
//            self._tmpUrl = webView.request?.url?.absoluteString;
//        }
        
        self.createAccessCookie()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if webView.request!.url!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            self.runScript("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
        
        print("dong3 back do? \(webView.scrollView.contentOffset.y)")
        
        self.webDelegate?.webLoadedCommit(webView.request?.url?.absoluteString)
        self.webDelegate?.webLoadedFinish(webView.request?.url?.absoluteString)
    }

    
  
    
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
     
     func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
     let alertController = UIAlertController(title: "알림", message: message,
     preferredStyle: UIAlertControllerStyle.Alert);
     
     alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
     _ in completionHandler()}
     );
     
     self.presentViewController(alertController, animated: true, completion: {});
     }
     
     func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
     
     let alertController = UIAlertController(title: "확인", message: message,
     preferredStyle: UIAlertControllerStyle.Alert);
     
     alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
     _ in completionHandler(true)}
     );
     alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
     _ in completionHandler(false)}
     );
     
     self.presentViewController(alertController, animated: true, completion: {});
     
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
    
    
    
    func interceptWebView(_ url:URL) -> Bool {
//        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
//            if UIApplication.shared.canOpenURL(URL(string:"smartxpay-transfer://")!) {
//                UIApplication.shared.openURL(url)
//            }else{
//                popup("확인버튼을 누르시면 스토어로 이동합니다.",handler: { action in
//                    let itunes = "https://itunes.apple.com/kr/app/seumateu-egseupei-gyejwaiche/id393794374?mt=8"
//                    UIApplication.shared.openURL(URL(string:itunes)!)
//                })
//            }
//            return false
//        }
//        if url.absoluteString.hasPrefix("paypin://MP_2APP"){
//            if UIApplication.shared.canOpenURL(URL(string:"paypin://MP_2APP")!) {
//                UIApplication.shared.openURL(url)
//            }else{
//                popup("확인버튼을 누르시면 스토어로 이동합니다.")
//            }
//            return false
//        }
//        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
//            if UIApplication.shared.canOpenURL(URL(string:"smartxpay-transfer://")!) {
//                UIApplication.shared.openURL(url)
//            }else{
//                popup("확인버튼을 누르시면 스토어로 이동합니다.")
//            }
//            return false
//        }
//
        for appSchema in paySchema {
            if url.absoluteString.hasPrefix(appSchema["schema"]! as String) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }else{
                    UIApplication.shared.openURL(URL(string:appSchema["url"]! as String)!)
                }
                return false
            }
        }
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("dong3 error erorr \(error)")
    }
    
    override func runScript(_ script: String) {
        _webView.stringByEvaluatingJavaScript(from: script)
    }
    
    override var canGoBack: Bool {
        get{ return _webView.canGoBack }
    }
    override var canGoForward: Bool{
        get { return _webView.canGoForward }
    }
    override var currentURL: URL?{
        get{ return _webView.request?.url }
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
