//
//  WMainController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WMainController: BaseWebController,WebControlDelegate {
    
    weak var introContrller:WIntroController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.engine.webDelegate = self
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "intro", sender: self)
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

    func reqMatchingForLogin(_ movePage:String){

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

    func reqSetLoginStat(_ yn:String){
        let userInfo = WInfo.userInfo
        if let member_id = userInfo["userId"] as? String{
            let resource = ApiFormApp().ap("mode","set_login_stat").ap("pack_name",AppProp.appId).ap("login_stat",yn).ap("member_id",member_id)
            RSHttp(controller: nil, progress: false, showingPopup: false).req(resource) { (resource) -> (Void) in
                
            }
        }
    }

    func reqLogin(_ movePage:String) {
        let userInfo = WInfo.userInfo
        var id_save = "N"
        var pw_save = "N"
        WInfo.getCookieValue(key: "wisamall_id") { (value) in
            id_save = value == nil ? "N" : "Y"
            WInfo.getCookieValue(key: "wisamall_pw") { (value) in
                pw_save = value == nil ? "N" : "Y"
                RSHttp(controller:self,showingPopup:false).req(
                    [WingLogin().ap("member_id",userInfo["userId"] as! String)
                        .ap("pwd",userInfo["password"] as! String)
                        .ap("id_save",id_save)
                        .ap("pw_save",pw_save)
                        .ap("exec_file","member/login.exe.php")],
                    successCb: { (resource) -> Void in
                        self.loadPage(movePage)
                        self.reqSetLoginStat("Y")
                },
                    errorCb : { (errorCode,resource) -> Void in
                        WInfo.userInfo = [String:AnyObject]()
                        self.loadPage(movePage)
                        self.reqSetLoginStat("N")
                }
                )
            }
        }
   
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
        if (WInfo.userInfo.count != 0) {
            self.reqMatchingForLogin(WInfo.appUrl)
        }else{
            loadPage(WInfo.appUrl)
        }
    }


    func loadPage(_ url:String){
        
        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
        let objTopFix = ui_data["isTopFix"] as? Bool
        let topFix = objTopFix == nil ? true : objTopFix!
        if topFix && statusOverlay != nil{
            self.statusOverlay!.frame = CGRect(x:0 ,y:0,width:self.webViewContainer.frame.width ,height:
                UIApplication.shared.statusBarFrame.height)
        }else{
            self.statusOverlay?.isHidden = true
            DispatchQueue.main.async{
                self.engine.scrollView.contentInset.top = 0
            }
        }
        var url_obj = URL (string: url);
        
        if url == WInfo.appUrl {
            let new_url = "\(WInfo.appUrl)?\(WInfo.urlParam)"
            url_obj = URL (string: new_url);
        }

        
        let requestObj = NSMutableURLRequest(url: url_obj!);
        requestObj.httpShouldHandleCookies = true
        view.isHidden = false
        
        self.engine.loadRequest(requestObj as URLRequest)
        
        if let appDelegate = UIApplication.shared.delegate as? WAppDelegate {
            if appDelegate.remotePushSeq != nil {
                RSHttp().req( ApiFormApp().ap("mode","get_push_data").ap("pack_name",AppProp.appId).ap("push_seq",String(appDelegate.remotePushSeq!)),successCb : { (resource) -> Void in
                    let objectInfo = resource.body()["data"] as! [String:AnyObject]
                    let link = objectInfo["link"] as? String
                    let type = objectInfo["type"] as? String
                    appDelegate.goNotificationLink(link!, type!)
                })
                appDelegate.remotePushSeq = nil
            }
            if appDelegate.commmandUrl != nil {
                if appDelegate.commmandUrl!.hasPrefix("http") || appDelegate.commmandUrl!.hasPrefix("https") {
                    appDelegate.commmandUrl = nil
                    let requestObj = NSMutableURLRequest(url: URL(string: appDelegate.commmandUrl!)!);
                    requestObj.httpShouldHandleCookies = true
                    self.engine.loadRequest(requestObj as URLRequest)
                }
            }
        }
    
      

    } 
    
    
    func movePage(_ page:String){
        var url_obj = URL (string: page);
        if page == WInfo.appUrl {
            let new_url = "\(WInfo.appUrl)?\(WInfo.urlParam)"
            url_obj = URL (string: new_url);
        }
        let requestObj = NSMutableURLRequest(url: url_obj!);
//        requestObj.addValue(WInfo.defaultCookie(),forHTTPHeaderField:"Cookie")
        engine.loadRequest(requestObj as URLRequest)
    }
    

    func applyAction(_ button:UIButton,key:String){
        if key == "prev"{
            button.addTarget(self , action: #selector(WMainController.onPrevClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "next"{
            button.addTarget(self , action: #selector(WMainController.onNextClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "reload"{
            button.addTarget(self , action: #selector(WMainController.onReloadClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "home"{
            button.addTarget(self , action: #selector(WMainController.onHomeClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "share"{
            button.addTarget(self , action: #selector(WMainController.onShareClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "push"{
            button.addTarget(self , action: #selector(WMainController.onPushClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "tab"{
        }else if key == "setting"{
            button.addTarget(self , action: #selector(WMainController.onSettingClick(_:)) , for: UIControlEvents.touchUpInside)
            
        }
    }    


    @objc func onPrevClick(_ sender:UIButton!){
        if self.engine.canGoBack {
            self.engine.goBack()
        }else{
           self.view.makeToast("이동할 페이지가 없습니다.", duration: 3.0, position: .bottom) 
        }
    }
    @objc func onNextClick(_ sender:UIButton!){
        if self.engine.canGoForward {
            self.engine.goForward()
        }else{
           self.view.makeToast("이동할 페이지가 없습니다.", duration: 3.0, position: .bottom) 
       }
    }
    @objc func onReloadClick(_ sender:UIButton!){
        self.engine.reload()
    }
    @objc func onHomeClick(_ sender:UIButton!){
        let url = URL (string: WInfo.appUrl);
        let requestObj = NSMutableURLRequest(url: url!);
//        requestObj.addValue(WInfo.defaultCookie(),forHTTPHeaderField:"Cookie")
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onShareClick(_ sender:UIButton!){
        self.engine.sharedUrl()
    }
    @objc func onPushClick(_ sender:UIButton!){
        self.performSegue(withIdentifier: "noti" ,  sender : nil)
    }
    @objc func onSettingClick(_ sender:UIButton!){
        self.performSegue(withIdentifier: "setting" ,  sender : self)
    }
    
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier == "noti" {
            let notiController = segue.destination as! WNotiController
            let data = sender as? Array<String>;
            notiController.link = data![0]
            notiController.type = data![1]
        } else if segue.identifier == "intro"{
            self.introContrller = segue.destination as? WIntroController
            self.introContrller!.mainController = self
        } else if segue.identifier == "permission"{
        }
    }
    
    
    
    /* WebControl Delegate */
    func hybridEvent(_ value: [String : AnyObject]) {
        if value["func"] as! String == "saveMinfo"{
            WInfo.userInfo = [ "userId" : value["param1"] as! String as AnyObject , "password" : value["param2"] as! String as AnyObject ]
            self.reqSetLoginStat("Y")
            self.reqMatching()
            movePage(value["param3"] as! String)
        }
    }
    func webLoadedCommit(_ urlString: String?) {
        if self.presentedViewController != nil {
            self.introContrller?.webViewLoadedOk = true
            self.introContrller?.closeIntroProcess()
        }
        
        //        #if DEBUG
        //
        //            webView.stringByEvaluatingJavaScript(from: "if($.wsmk == undefined) $.getScript('http://admin.magicapp.co.kr/ws_magic_v2.js');");
        //            webView.stringByEvaluatingJavaScript(from: "if($('#menu-barcode').length == 0) $('.list.mypage ul').append( $('<li/>').html('<a href=\"javascript:$.wsmk.scanner(function(resp){ alert(JSON.stringify(resp) ); } )\">바코드 인식</a>') )");
        //
        //        #endif
        

    }
    
    func webLoadedFinish(_ urlString:String?){
        
    }


}

