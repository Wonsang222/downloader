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
        print(WInfo.userInfo)
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
        webView.loadRequest(requestObj);
        view.hidden = false
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
        let objectToShare = [webView.request!.URL!]
        let activity = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)

        presentViewController(activity, animated: true, completion: nil)
    }
    func onPushClick(sender:UIButton!){
        self.performSegueWithIdentifier("noti" ,  sender : self)
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

}

