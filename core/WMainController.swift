//
//  WMainController.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 18..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit

class WMainController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!

    weak var introController:WIntroController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.WIntroController = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("introController") as WIntroController
        self.presentViewController(self.WIntroController,animated:false,completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func endIntro(){
        do{
            try applyTheme()
        }catch{
            WInfo.themeInfo = [String:AnyObject]()
            NSApplication.sharedApplication().terminate(self)
        }


    }

    func reqLogin(){
        let userInfo = WInfo.userInfo
        RSHttp(controller:self).req(
           WingLogin().ap("member_id",userInfo["userId"])
                        .ap("pwd",userInfo["password"]),
                        .ap("exec_file","member/login.exe.php")
           successCb: { (resource) -> Void in
                self.reqMatching()
           },
           errorCb : { (errorCode,resource) -> Void in
                WInfo.userInfo = [String:AnyObject]()
                self.loadPage()
           }
        )
    }

    func reqMatching(){
        // Todo : reqMatching
        RSHttp(controller:self).req(
           ApiFormApp().ap("mode","matching")
                        .ap("pack_name",AppProp.appId),
                        .ap("token","GCM_KEY"),
                        .ap("member_id",WInfo.userInfo["userId"])
           successCb: { (resource) -> Void in
                self.reqMatching()
           },
           errorCb : { (errorCode,resource) -> Void in
                WInfo.userInfo = [String:AnyObject]()
                self.loadPage()
           }
        )        

    }

    // Abstract
    func applyTheme() throws{

    }

    func applyThemeFinish(){
        if (WInfo.solutionType == "W") && (WInfo.userInfo.count != 0) {
            self.reqLogin()
        }else{
            loadPage()
        }

    }

    func loadPage(){
        // Todo : GCM Connect
        let url = NSURL (string: WInfo.appUrl);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
    }





    func applyAction(button:UIButton,key:String){
        if key == "prev"{
            button.addTarget(self , action: "onPrevClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "next"{
            button.addTarget(self , action: "onNextClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "reload"{
            button.addTarget(self , action: "onReloadClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "home"{
            button.addTarget(self , action: "onHomeClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "share"{
            button.addTarget(self , action: "onShareClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "push"{
            button.addTarget(self , action: "onPushClick:" , forControlEvents: UIControlEvents.TouchUpInside)
        }else if key == "tab"{
        }else if key == "setting"{
            button.addTarget(self , action: "onSettingClick:" , forControlEvents: UIControlEvents.TouchUpInside)
            
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
    }
    func onPushClick(sender:UIButton!){
        self.performSegueWithIdentifier("noti" ,  sender : self)
    }
    func onSettingClick(sender:UIButton!){
        self.performSegueWithIdentifier("setting" ,  sender : self)
    }
     

}

