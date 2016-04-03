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
        self.introController = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("introController") as! WIntroController
        self.introController.mainController = self
        self.presentViewController(self.introController,animated:false,completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func endIntro(){
        do{
            try applyTheme()
        }catch{
            WInfo.themeInfo = [String:AnyObject]()
            exit(0)
        }


    }

    func reqLogin(){
        let userInfo = WInfo.userInfo
        RSHttp(controller:self).req(
           [WingLogin().ap("member_id",userInfo["userId"] as! String)
                        .ap("pwd",userInfo["password"] as! String)
                        .ap("exec_file","member/login.exe.php")],
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
           [ApiFormApp().ap("mode","matching")
                        .ap("pack_name",AppProp.appId)
                        .ap("token","GCM_KEY")
                        .ap("member_id",WInfo.userInfo["userId"] as! String)],
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
        webView.scrollView.contentInset.top = 0
        print(webView.scrollView.contentInset.top)
        webView.loadRequest(requestObj);
    }

}

