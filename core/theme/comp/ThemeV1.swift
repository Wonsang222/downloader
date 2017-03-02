//
//  ThemeV1.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeV1: CommonMkTheme {
    
    let menuMap = [
        "prev"      :"ic_a_prev.png",
        "next"      :"ic_a_next.png",
        "reload"    :"ic_a_refresh.png",
        "home"      :"ic_a_home.png",
        "share"     :"ic_a_share.png",
        "push"      :"ic_a_menu.png",
        "setting"   :"ic_a_tab.png"
    ]

    
    override func applayMain() {
        
        let view = self.viewController.view
        
        let mainController = self.viewController as? MainController
        if mainController == nil {
            return
        }
        
        let menus = uiData["menus"] as! [[String:AnyObject]]
        let menuSize = CGFloat((uiData["menusSize"] as! NSString).floatValue)
        let wisaMenu:UIView = UIView(frame : CGRectMake(0,view.frame.height - menuSize,UIScreen.mainScreen().bounds.width, menuSize) )
        let menuWidth = UIScreen.mainScreen().bounds.width / CGFloat(menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
        let iconColor = UIColor(hexString:uiData["menuIcon"] as! String)
        let iconDisable = UIColor(hexString:uiData["menuIcon"] as! String)
        
        wisaMenu.userInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        var position = CGFloat(0)
        for menu in menus {
            let menuView = UIButton(frame : CGRectMake(CGFloat(position), 0 , menuWidth ,wisaMenu.frame.height))
            let key = menu["click"] as! String
            let menuIcon = UIImage(named : menuMap[key]!)!
            let menuIconDisable = UIImage(named: menuMap[key]!.replace(".png", withString: "_disable.png"))!
            let newMenuBg = menuIcon.makeFillImage(menuView)
            let newMenuBgDisable = menuIconDisable.makeFillImage(menuView)
            menuView.setBackgroundImage(newMenuBg.tintWithColor(iconColor), forState: .Normal)
            menuView.setBackgroundImage(newMenuBgDisable.tintWithColor(iconDisable), forState: .Disabled)
            menuView.showsTouchWhenHighlighted = true
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += menuWidth
            
            if key == "next" {
                mainController?.nextBtn = menuView
                menuView.enabled = false
            }
            if key == "prev" {
                mainController?.prevBtn = menuView
                menuView.enabled = false
            }
            
            if key == "push" {
                let newView = UIImageView(image: UIImage(named: "ic_a_isnew.png"))
                mainController?.isNewBadge = newView
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
        view.addSubview(wisaMenu)
        mainController!.webView.scrollView.contentInset.bottom = menuSize
        
    }
    
    override func applyNavi() {
    
        let labelViewTag = 100
        let backTag = 101
        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
        let naviBar = ui_data["navibar"] as! [String:AnyObject]
        
        let topView = self.viewController.view.subviews[1]
        let titleView = topView.viewWithTag(labelViewTag) as! UILabel
        let back_button = topView.viewWithTag(backTag) as! UIButton
        let height = CGFloat(naviBar["height"] as! Int)
        topView.backgroundColor = UIColor(hexString:naviBar["bg"] as! String)

        topView.frame = CGRectMake(0, 0, CGRectGetWidth(topView.frame), CGFloat(height + 20))
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString: "#cbcbcb").CGColor
        borderLayer.frame = CGRectMake(0, CGRectGetHeight(topView.frame) - 1.0 , CGRectGetWidth(topView.frame), Tools.toOriginPixel(1.0))
        topView.layer.addSublayer(borderLayer)
        titleView.font = UIFont.boldSystemFontOfSize(CGFloat(naviBar["title_size"] as! Int ))
        titleView.textColor = UIColor(hexString: naviBar["title_color"] as! String )
        back_button.frame = CGRectMake(0, 0, height,height)

        
        
        
        
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
