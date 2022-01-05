//
//  WMainController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class WMainController: BaseWebController,WebControlDelegate, UIScrollViewDelegate {
    
    weak var introContrller:WIntroController?
    // nain
    var openedButton: UIButton? = nil
    var menuState: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.engine.webDelegate = self
        self.engine.scrollView.delegate = self
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
            DispatchQueue.main.async{
                self.engine.scrollView.contentInset.top = 0
            }
            self.statusOverlay!.frame = CGRect(x:0 ,y:0,width:self.webViewContainer.frame.width ,height:
                UIApplication.shared.statusBarFrame.height)
        }
        else{
            self.statusOverlay?.isHidden = true
            DispatchQueue.main.async{
                self.engine.scrollView.contentInset.top = 0
            }
        }
        var url_obj = URL (string: url);
        if url == WInfo.appUrl {
            // 'wsmk=' 값만 넘어온다면 파라미터 넣지않기
            if WInfo.urlParam != "wsmk=" {
                let new_url = "\(WInfo.appUrl)?\(WInfo.urlParam)"
                url_obj = URL (string: new_url);
            }
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
                    let type = objectInfo["type"] as? String == "notice" ? "event" : "all"                    
                    appDelegate.goNotificationLink(link!, type)
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
    @objc func onMoreClick(_ sender:UIButton!){
        // toggle
        let extendsArrow:UIView! = sender.subviews[2];
        
        if let extendsMenu = sender.superview?.superview?.viewWithTag(WInfo.extendThemeTag) {
            if extendsMenu.isHidden == false {
                UIView.animate(withDuration: 0.2, animations: {
                    extendsMenu.frame = extendsMenu.frame.changeY(self.view!.frame.height - 50 - Tools.safeArea() - 0.5)
                    extendsArrow.alpha = 0.0
                }) { (bool) in
                    extendsMenu.isHidden = true
                    extendsArrow.isHidden = true
                }
            } else {
                extendsMenu.isHidden = false
                extendsArrow.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    extendsMenu.frame =
                        extendsMenu.frame.changeY(self.view!.frame.height - 120 - Tools.safeArea() - 0.5)
                    extendsArrow.alpha = 1.0
                }) { (bool) in
                }
            }
        }
        
    }
    
    @objc func onExtendFunc(_ sender:UIButton!, _ key: String) {
        if key == "prev"{
            self.onPrevClick(sender)
        }else if key == "next"{
            self.onNextClick(sender)
        }else if key == "reload"{
            self.onReloadClick(sender)
        }else if key == "home"{
            self.onHomeClick(sender)
        }else if key == "share"{
            self.onShareClick(sender)
        }else if key == "push"{
            self.onPushClick(sender)
        }else if key == "setting"{
            self.onSettingClick(sender)
        }else if key == "more"{
            openedButton = sender;
            self.onMoreClick(sender)
        }else {
            let url = URL(string: String(describing: "\(WInfo.appUrl)/\(key)"))
            let requestObj = NSMutableURLRequest(url: url!)
            self.engine.loadRequest(requestObj as URLRequest)
        }
        
    }
    //
    
    // NAIN custom
    @objc func openLayout(_ sender: UIButton) {
        let layout1 =  sender.superview! as UIView
        let root = layout1.superview! as UIView
        openedButton = root.subviews[2].subviews[5] as? UIButton

        root.subviews[2].transform = CGAffineTransform(translationX: layout1.rsX, y: 100)
        sender.isHidden = true
        layout1.subviews[8].isHidden = false
        root.subviews[2].isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            
            root.subviews[2].transform = CGAffineTransform(translationX: layout1.rsX, y: 0)
        }) { (finish) in
            
        }
    }
    
    @objc func closeLayout(_ sender: UIButton) {
        let extendsMenu:UIView! = sender.superview?.superview?.subviews[2];
        let extendsArrow:UIView! = sender.subviews[2];
        
        if extendsMenu.isHidden == false {
            UIView.animate(withDuration: 0.2, animations: {
                extendsMenu.frame = extendsMenu.frame.changeY(self.view!.frame.height - 50 - Tools.safeArea() - 0.5)
                extendsArrow.alpha = 0.0
            }) { (bool) in
                extendsMenu.isHidden = true
                extendsArrow.isHidden = true
            }
        }
    }
    
    // url 뒤에부분은 서버에서 json으로 내리기
    
    @objc func onLoginClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/member/login.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onMypageClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/mypage/mypage.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onLatestPrdClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/shop/click_prd.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onWishClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/mypage/wish_list.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onCartClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/shop/cart.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onDeliverClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/mypage/order_list.php");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    @objc func onLocationClick(_ sender: UIButton) {
        let url = URL (string: "\(WInfo.appUrl)/board/?db=basic_1");
        let requestObj = NSMutableURLRequest(url: url!);
        self.engine.loadRequest(requestObj as URLRequest)
    }
    
//}else if key == "latest_prd"{
//    button.addTarget(self.viewController , action: #selector(WMainController.onLatestPrdClick(_:)) , for: UIControlEvents.touchUpInside)
//}else if key == "wish"{
//    button.addTarget(self.viewController , action: #selector(WMainController.onWishClick(_:)) , for: UIControlEvents.touchUpInside)
//}else if key == "cart"{
//    button.addTarget(self.viewController , action: #selector(WMainController.onCartClick(_:)) , for: UIControlEvents.touchUpInside)
//}else if key == "deliver"{
//    button.addTarget(self.viewController , action: #selector(WMainController.onDeliverClick(_:)) , for: UIControlEvents.touchUpInside)
//}else if key == "location"{
//    button.addTarget(self.viewController , action: #selector(WMainController.onLocationClick(_:)) , for: UIControlEvents.touchUpInside)
//}else if key == "setting"{
    
    override func prepare(for segue:UIStoryboardSegue, sender: Any?){
        if segue.identifier == "noti" {
            let notiController = segue.destination as! WNotiController
            if let data = sender as? Array<String> {
                if data.count == 2 {
                    notiController.link = data[0]
                    notiController.type = data[1]
                }
            } else {
                notiController.link = sender as? String
            }
            
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if openedButton == nil {
            return ;
        } else {
            self.closeLayout(openedButton!)
        }
    }
}

