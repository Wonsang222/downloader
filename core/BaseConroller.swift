//
//  BaseController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit
class BaseController: UIViewController {

	@IBOutlet weak var topView: UIView?
    @IBOutlet var topTitle:UILabel?
 
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let tracker = (UIApplication.sharedApplication().delegate as! WAppDelegate).tracker {
            if let title = self.title {
                if !title.isEmpty{
                    tracker.set(kGAIScreenName, value: self.title!)
                    let builder = GAIDictionaryBuilder.createScreenView()
                    tracker.send(builder.build() as [NSObject : AnyObject])
                }
            }
        }
    }
    
    
    @IBAction func doBack(sender:AnyObject){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

class BaseWebViewController: BaseController,UIWebViewDelegate {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    var webView:UIWebView!
    
    
    let paySchema = [
        ["schema" : "hdcardappcardansimclick", "url" : "http://itunes.apple.com/kr/app/id702653088?mt=8"],  //현대카드
        ["schema" : "shinhan-sr-ansimclick", "url" : "https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8"], //신한카드
        ["schema" : "kb-acp", "url" : "https://itunes.apple.com/kr/app/kbgugmin-aebkadue/id695436326?mt=8"],    //KB카드
        ["schema" : "mpocket.online.ansimclick", "url" : "https://itunes.apple.com/kr/app/mpokes/id535125356?mt=8&ls=1"], // 삼성카드
        ["schema" : "tswansimclick", "url" : "https://itunes.apple.com/kr/app/id430282710"],   //삼성 서랍

        ["schema" : "lotteappcard", "url" : "https://itunes.apple.com/kr/app/losde-aebkadeu/id688047200?mt=8"], //롯데카드
        ["schema" : "cloudpay", "url" : "itmss://itunes.apple.com/app/id847268987"], //외환카드 , 하나카드
        ["schema" : "nhappcardansimclick", "url" : "http://itunes.apple.com/kr/app/nhnonghyeob-mobailkadeu-aebkadeu/id698023004?mt=8"], //NH카드
        ["schema" : "citispay", "url" : "https://itunes.apple.com/kr/app/citi-cards-mobile-ssitikadeu/id373559493?l=en&mt=8"],          //NH카드
        ["schema" : "lguthepay", "url" : "https://itunes.apple.com/kr/app/paynow/id760098906?mt=8"],          //페이나우
        
        ["schema" : "smhyundaiansimclick", "url" : ""],
        ["schema" : "nonghyupcardansimclick", "url" : ""],
        
        ["schema" : "lguthepay", "url" : ""],
        ["schema" : "payco", "url" : ""],
        
        ["schema" : "ispmobile", "url" : "https://itunes.apple.com/kr/app/mobail-anjeongyeolje-isp/id369125087?mt=8"]   // ISP 
    ]
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: webViewContainer.bounds)
        webView.allowsInlineMediaPlayback = true
        
        let userAgent = webView.stringByEvaluatingJavaScriptFromString("navigator.userAgent")!;
        NSUserDefaults.standardUserDefaults().registerDefaults(
            ["UserAgent":
                userAgent + " WISAAPP/" + AppProp.appId + "/" + AppProp.appVersion]
        )
        if #available(iOS 9, *) {
            webView.allowsLinkPreview = true
            webView.allowsPictureInPictureMediaPlayback = true
        }

        webView.delegate = self
        webView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]

        webViewContainer.addSubview(webView)
    }
    
    func reloadPage(){
        print("reloadPage")
        self.webView.reload()
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWithRequest \(request.URL!) navigationType \(navigationType)")
        var backgroundSupported = false
        let device = UIDevice.currentDevice()
        if device.respondsToSelector(Selector("isMultitaskingSupported")){
            backgroundSupported = device.multitaskingSupported;
        }
        if !backgroundSupported {
            popup("멀티테스킹을 지원하는 기기 또한 어플만 공인인증서비스가 가능합니다.")
            return true
        }
//        if request.URL!.absoluteString == "about:blank" {
//            UIWebView(frame: CGRectZero).loadRequest(request)
//            return false
//        }

        
        if request.URL!.absoluteString.hasPrefix("wisamagic://event?json=") {
            let json = request.URL?.absoluteString.replace("wisamagic://event?json=", withString: "")
            do{
                let json_decode = json!.stringByRemovingPercentEncoding
                let value = try
                            NSJSONSerialization.JSONObjectWithData(
                            json_decode!.dataUsingEncoding(NSUTF8StringEncoding)!
                            ,options: NSJSONReadingOptions()) as! [String:AnyObject]
                hybridEvent(value)
            }catch{
                
            }
            return false
        }
       
        let returval = interceptWebView(request.URL!)
        print(returval)
        return returval
    }
    
    func webViewDidStartLoad(webView: UIWebView){
        print("start " + webView.request!.URL!.absoluteString)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let access_cookie_dic : [String:AnyObject] = [
            NSHTTPCookieDomain : WInfo.appUrl.replace("http://", withString: "").replace("https://", withString: ""),
            NSHTTPCookiePath : "/",
            NSHTTPCookieName : "wisamall_access_device",
            NSHTTPCookieValue : "APP",
            NSHTTPCookieExpires : NSDate().dateByAddingTimeInterval(60*60*24*365*300)
        ];
        let cookie:NSHTTPCookie = NSHTTPCookie(properties: access_cookie_dic)!
        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
//        progressView.setProgress(0, animated: false)
//        progressView.setProgress(0.8, animated: true)
//        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressView.alpha = 1 }, completion: nil)
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("end " + webView.request!.URL!.absoluteString)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if webView.request!.URL!.absoluteString.hasSuffix("smpay.kcp.co.kr/card.do") {
            webView.stringByEvaluatingJavaScriptFromString("document.getElementById('layer_mpi').contentWindow.open = function(url,frame,feature) { }")
        }
//        progressView.setProgress(1, animated: true)
//        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressView.alpha = 0 }, completion: nil)

    }
    
    func hybridEvent(value: [String:AnyObject]){
        
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
    
    
     
    func interceptWebView(url:NSURL) -> Bool {
        if url.absoluteString.hasSuffix("exec_file=member/logout.exe.php") {
            WInfo.clearCookie()
            WInfo.userInfo = [String:AnyObject]()
            return true
        }
        let device = UIDevice.currentDevice()
        if !device.multitaskingSupported {
            popup("멀티테스킹을 지원하는 기기 또는 어플만  공인인증서비스가 가능합니다.")
            return false;
        }

        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
            if UIApplication.sharedApplication().canOpenURL(NSURL(string:"smartxpay-transfer://")!) {
                UIApplication.sharedApplication().openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.",handler: { action in
                    let itunes = "https://itunes.apple.com/kr/app/seumateu-egseupei-gyejwaiche/id393794374?mt=8"
                    UIApplication.sharedApplication().openURL(NSURL(string:itunes)!)
                })
            }
            return false
        }
        if url.absoluteString.hasPrefix("paypin://MP_2APP"){
            if UIApplication.sharedApplication().canOpenURL(NSURL(string:"paypin://MP_2APP")!) {
                UIApplication.sharedApplication().openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.")
            }
            return false
        }
        if url.absoluteString.hasPrefix("smartxpay-transfer://"){
            if UIApplication.sharedApplication().canOpenURL(NSURL(string:"smartxpay-transfer://")!) {
                UIApplication.sharedApplication().openURL(url)
            }else{
                popup("확인버튼을 누르시면 스토어로 이동합니다.")
            }
            return false
        }
        
        
        
        if url.absoluteString.hasPrefix("https://itunes.apple.com/kr/app/") {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("https://itunes.apple.com/us/app/") {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("http://itunes.apple.com/us/app/") {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("http://itunes.apple.com/kr/app/") {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        if url.absoluteString.hasPrefix("itms-appss://") {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        
        for appSchema in paySchema {
            if url.absoluteString.hasPrefix(appSchema["schema"]! as String) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    UIApplication.sharedApplication().openURL(url)
                }else{
                    UIApplication.sharedApplication().openURL(NSURL(string:appSchema["url"]! as String)!)
                }
                return false
            }
        }
        return true
    }
    
    
    
    func popup(message:String){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.Default, handler:nil))
        self.presentViewController(alert,animated:true, completion: nil)
    }
    
    func popup(message:String,handler:((UIAlertAction) -> Void)){
        let alert = UIAlertController(title: "알림", message: message ,preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "확인" , style: UIAlertActionStyle.Default, handler:handler))
        self.presentViewController(alert,animated:true, completion: nil)
    }
    
}

