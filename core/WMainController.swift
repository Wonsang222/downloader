//
//  WMainController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WMainController: BaseWebViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("intro", sender: self)
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func endIntro(){
        do{
            try self.applyTheme()
        }catch{
            WInfo.themeInfo = [String:AnyObject]()
            exit(0)
        }
    }

    func reqMatchingForLogin(movePage:String){

        // Matching
        RSHttp(controller:self,showingPopup:false).req(
            [ApiFormApp().ap("mode","matching")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
                .ap("member_id",WInfo.userInfo["userId"] as! String)],
            successCb: { (resource) -> Void in
                // Login
                self.reqLogin(movePage)
            },
            errorCb : { (errorCode,resource) -> Void in
                WInfo.userInfo = [String:AnyObject]()
                self.loadPage(movePage)
            }
        )
        
        
    }

    

    func reqLogin(movePage:String) {
        let userInfo = WInfo.userInfo
        RSHttp(controller:self,showingPopup:false).req(
            [WingLogin().ap("member_id",userInfo["userId"] as! String)
                .ap("pwd",userInfo["password"] as! String)
                .ap("exec_file","member/login.exe.php")],
            successCb: { (resource) -> Void in
                self.loadPage(movePage)
            },
            errorCb : { (errorCode,resource) -> Void in
                WInfo.userInfo = [String:AnyObject]()
                self.loadPage(movePage)
            }
        )
    }
    
    
    
    func reqMatching(){
        
        // Matching
        RSHttp(controller:self).req(
            ApiFormApp().ap("mode","matching")
                .ap("pack_name",AppProp.appId)
                .ap("token",WInfo.deviceToken)
                .ap("member_id",WInfo.userInfo["userId"] as! String)
        )
        
        
    }
    
    
    // Abstract
    func applyTheme() throws{

    }

    func applyThemeFinish(){
    }
    
    func beginController(){
        if (WInfo.solutionType == "W") && (WInfo.userInfo.count != 0) {
            self.reqMatchingForLogin(WInfo.appUrl)
        }else{
            loadPage(WInfo.appUrl)
        }
    }

    func loadPage(url:String){
        
        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
        let topFix = ui_data["isTopFix"] as? Bool
        if topFix != nil && topFix!{
            dispatch_async(dispatch_get_main_queue()){
                self.webViewContainer.frame = CGRectInset(self.webViewContainer.frame, 0, 20)
                self.webView.scrollView.contentInset.top = 0
            }
        }

        
        let script = "document.cookie = '\(WInfo.defaultCookie())'"
        let wkUserScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(wkUserScript)
        
        
        let url = NSURL (string: url);
        let requestObj = NSMutableURLRequest(URL: url!);
        requestObj.HTTPShouldHandleCookies = true
        requestObj.setValue(WInfo.defaultCookie(), forHTTPHeaderField: "Cookie")
        webView.loadRequest(requestObj)
        view.hidden = false
    }
    
    func movePage(page:String){
        let url = NSURL (string: page);
        let requestObj = NSMutableURLRequest(URL: url!);

        
        webView.loadRequest(requestObj);
    }


    override func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        let jsonString = message.body as! String
        do{
            let dic = try NSJSONSerialization.JSONObjectWithData(
                jsonString.dataUsingEncoding(NSUTF8StringEncoding)!,
                options: NSJSONReadingOptions()) as! [String:AnyObject]
            print(dic)
            if dic["func"] as! String == "saveMinfo"{
                WInfo.userInfo = [ "userId" : dic["param1"] as! String , "password" : dic["param2"] as! String ]
                self.reqMatching()
//                self.
                reqMatchingForLogin(dic["param3"] as! String)
            }
        }catch{
            
        }
    }


    func applyAction(button:UIButton,key:String){
        if key == "prev"{
            button.addTarget(self , action: #selector(WMainController.onPrevClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "next"{
            button.addTarget(self , action: #selector(WMainController.onNextClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "reload"{
            button.addTarget(self , action: #selector(WMainController.onReloadClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "home"{
            button.addTarget(self , action: #selector(WMainController.onHomeClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "share"{
            button.addTarget(self , action: #selector(WMainController.onShareClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "push"{
            button.addTarget(self , action: #selector(WMainController.onPushClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "tab"{
        }else if key == "setting"{
            button.addTarget(self , action: #selector(WMainController.onSettingClick(_:)) , forControlEvents: UIControlEvents.TouchUpInside)
            
        }
    }    


    func onPrevClick(sender:UIButton!){
        if webView.canGoBack {
            webView.goBack()
        }else{
           self.view.makeToast("이동할 페이지가 없습니다.", duration: 3.0, position: .Bottom) 
        }
    }
    func onNextClick(sender:UIButton!){
        if webView.canGoForward {
            webView.goForward()            
        }else{
           self.view.makeToast("이동할 페이지가 없습니다.", duration: 3.0, position: .Bottom) 
       }
    }
    func onReloadClick(sender:UIButton!){
        webView.reload()
    }
    func onHomeClick(sender:UIButton!){
        let url = NSURL (string: WInfo.appUrl);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
    }
    func onShareClick(sender:UIButton!){
        let objectToShare = [webView.URL!]
        let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)

        presentViewController(activity, animated: true, completion: nil)
    }
    func onPushClick(sender:UIButton!){
        self.performSegueWithIdentifier("noti" ,  sender : nil)
    }
    func onSettingClick(sender:UIButton!){
        self.performSegueWithIdentifier("setting" ,  sender : self)
    }

    override func prepareForSegue(segue:UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "noti" {
            let notiController = segue.destinationViewController as! WNotiController
            notiController.link = sender as? String
        } else if segue.identifier == "intro"{
            let introController = segue.destinationViewController as! WIntroController
            introController.mainController = self
        }
    }
    
    
    
    
    override func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        super.webView(webView, didFinishNavigation: navigation)
        
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}

