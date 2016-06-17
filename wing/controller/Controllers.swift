//
//  Controllers.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 24..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class IntroController:WIntroController{
    
}

class MainController:WMainController{
    
    let menuMap = [
        "prev"      :"ic_a_prev.png",
        "next"      :"ic_a_next.png",
        "reload"    :"ic_a_refresh.png",
        "home"      :"ic_a_home.png",
        "share"     :"ic_a_share.png",
        "push"      :"ic_a_menu.png",
        "setting"   :"ic_a_tab.png"
    ]
    var nextBtn:UIButton?
    var prevBtn:UIButton?
    var isNewBadge:UIImageView?
    
    
    override func applyTheme() throws{

    	let uiData = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
    	let menus = uiData["menus"] as! [[String:AnyObject]]
        let menuSize = CGFloat((uiData["menusSize"] as! NSString).floatValue)
    	let wisaMenu:UIView = UIView(frame : CGRectMake(0,self.view.frame.height - menuSize,UIScreen.mainScreen().bounds.width, menuSize) )
    	let menuWidth = UIScreen.mainScreen().bounds.width / CGFloat(menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
        wisaMenu.userInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        var position = CGFloat(0)
    	for menu in menus {
    		let menuView = UIButton(frame : CGRectMake(CGFloat(position), 0 , menuWidth ,wisaMenu.frame.height))
            let key = menu["click"] as! String
            let menuIcon = UIImage(named : menuMap[key]!)!
            let menuIconDisable = UIImage(named: menuMap[key]!.replace(".png", withString: "_disable.png"))!

            let newMenuBg = menuIcon.makeFillImage(menuView,bgColor:bgColor)
            let newMenuBgDisable = menuIconDisable.makeFillImage(menuView,bgColor:bgColor)
            menuView.setBackgroundImage(newMenuBg, forState: .Normal)
            menuView.setBackgroundImage(newMenuBgDisable, forState: .Disabled)
            menuView.showsTouchWhenHighlighted = true
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += menuWidth
            
            if key == "next" {
                nextBtn = menuView
                menuView.enabled = false
            }
            if key == "prev" {
                prevBtn = menuView
                menuView.enabled = false
            }
            
            if key == "push" {
                let newView = UIImageView(image: UIImage(named: "ic_a_isnew.png"))
                isNewBadge = newView
                newView.frame = CGRectMake(menuView.frame.origin.x + 30,
                                           0,
                                           CGRectGetWidth(newView.frame)/UIScreen.mainScreen().scale,
                                           CGRectGetHeight(newView.frame)/UIScreen.mainScreen().scale)
                newView.center.y = menuView.center.y
                menuView.addSubview(newView)
            }
    	}
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").CGColor
        borderLayer.frame = CGRectMake(0, 0, CGRectGetWidth(wisaMenu.frame), Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
    	self.view.addSubview(wisaMenu)
        self.webView.scrollView.contentInset.bottom = menuSize
        self.beginController()
    }
    
    
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        if webView.canGoBack  {
            prevBtn?.enabled = true
        }else{
            prevBtn?.enabled = false
            
        }
        if webView.canGoForward {
            nextBtn?.enabled = true
            
        }else{
            nextBtn?.enabled = false
        }
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.sharedApplication().applicationIconBadgeNumber == 0 {
            isNewBadge?.hidden = true
        }else{
            isNewBadge?.hidden = false
        }
    }

}

class NotiController:WNotiController{
    
    override func viewDidLoad() {
        self.applyTopView()
        super.viewDidLoad()
    }
    
}

class SettingController:WSettingController{
    override func viewDidLoad() {
        self.applyTopView()
        super.viewDidLoad()
    }
}


extension BaseController{
    
    
    func applyTopView(){
        let labelViewTag = 100
        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
        let naviBar = ui_data["navibar"] as! [String:AnyObject]
          
        let topView = self.view.subviews[1]
        let contentView = self.view.subviews[0]
        let titleView = topView.viewWithTag(labelViewTag) as! UILabel

        topView.backgroundColor = UIColor(hexString:naviBar["bg"] as! String)
        topView.frame = CGRectMake(0, 0, CGRectGetWidth(topView.frame), CGFloat(naviBar["height"] as! Int + 20))
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString: "#cbcbcb").CGColor
        borderLayer.frame = CGRectMake(0, CGRectGetHeight(topView.frame) - 1.0 , CGRectGetWidth(topView.frame), Tools.toOriginPixel(1.0))
        topView.layer.addSublayer(borderLayer)
        titleView.font = UIFont.boldSystemFontOfSize(CGFloat(naviBar["title_size"] as! Int ))
        titleView.textColor = UIColor(hexString: naviBar["title_color"] as! String )
        contentView.frame = CGRectMake(0, CGRectGetHeight(topView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(topView.frame))
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let ui_data = WInfo.themeInfo["ui_data"] {
            let naviBar = ui_data["navibar"]! as! [String:AnyObject]
            let style = naviBar["status_style"]
            if style as! String == "Dark" {
                return .Default
            }else{
                return .LightContent
            }
        }else{
            return .Default

        }
        
    }
    

}



