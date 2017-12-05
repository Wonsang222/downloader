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
        let wisaMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - menuSize - Tools.safeArea(),width: UIScreen.main.bounds.width, height: menuSize) )

        let menuWidth = UIScreen.main.bounds.width / CGFloat(menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
        let iconColor = UIColor(hexString:uiData["menuIcon"] as! String)
        let iconDisable = UIColor(hexString:uiData["menuIcon"] as! String)
        
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        var position = CGFloat(0)
        for menu in menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: menuWidth ,height: wisaMenu.frame.height))
            let key = menu["click"] as! String
            let menuIcon = UIImage(named : menuMap[key]!)!
            let menuIconDisable = UIImage(named: menuMap[key]!.replace(".png", withString: "_disable.png"))!
            let newMenuBg = menuIcon.makeFillImage(menuView)
            let newMenuBgDisable = menuIconDisable.makeFillImage(menuView)
            menuView.setBackgroundImage(newMenuBg.tintWithColor(iconColor), for: UIControlState())
            menuView.setBackgroundImage(newMenuBgDisable.tintWithColor(iconDisable), for: .disabled)
            menuView.showsTouchWhenHighlighted = true
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += menuWidth
            
            if key == "next" {
                mainController?.nextBtn = menuView
                menuView.isEnabled = false
            }
            if key == "prev" {
                mainController?.prevBtn = menuView
                menuView.isEnabled = false
            }
            
            if key == "push" {
                let newView = UIImageView(image: UIImage(named: "ic_a_isnew.png"))
                mainController?.isNewBadge = newView
                newView.frame = CGRect(x: menuView.frame.origin.x + 30,
                                           y: 0,
                                           width: newView.frame.width/UIScreen.main.scale,
                                           height: newView.frame.height/UIScreen.main.scale)
                newView.center.y = menuView.center.y
                menuView.addSubview(newView)
            }
        }
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: wisaMenu.frame.width, height: Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
        view?.addSubview(wisaMenu)
        mainController!.webView.scrollView.contentInset.bottom = wisaMenu.frame.height
        if Tools.safeArea() != 0 {
            let safeView = UIView(frame: CGRect(x: 0, y: view!.frame.height - Tools.safeArea(), width: UIScreen.main.bounds.width, height: Tools.safeArea()))
            safeView.backgroundColor = UIColor(hexString:uiData["menusBg"] as! String)
            view?.addSubview(safeView)
        }
        if let webBackground = uiData["webBackground"] as? String {
            mainController!.webView.backgroundColor = UIColor(hexString:webBackground)
            mainController!.webView.isOpaque = false
        }else {
            mainController!.webView.backgroundColor = UIColor.white
            mainController!.webView.isOpaque = false
        }
        

    }
    
    override func applyNavi() {
    
        let labelViewTag = 100 
        let backTag = 101
        let naviBar = uiData["navibar"] as! [String:AnyObject]
        
        let topView = self.viewController.view.subviews[1]
        let titleView = topView.viewWithTag(labelViewTag) as! UILabel
        let back_button = topView.viewWithTag(backTag) as! UIButton
        let height = CGFloat( (naviBar["height"] as! NSNumber).floatValue )
        topView.backgroundColor = UIColor(hexString:naviBar["bg"] as! String)

        
        
        topView.frame = CGRect(x: 0, y: 0, width: topView.frame.width, height: CGFloat(height + UIApplication.shared.statusBarFrame.height))
        topView.subviews[0].frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height , width: topView.frame.width, height : height)
        
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString: "#cbcbcb").cgColor
        borderLayer.frame = CGRect(x: 0, y: topView.frame.height - 1.0 , width: topView.frame.width, height: Tools.toOriginPixel(1.0))
        topView.layer.addSublayer(borderLayer)
        titleView.font = UIFont.boldSystemFont(ofSize: CGFloat(naviBar["title_size"] as! Int ))
        titleView.textColor = UIColor(hexString: naviBar["title_color"] as! String )
        back_button.frame = CGRect(x: 0, y: 0, width: height,height: height)
        
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let ui_data = WInfo.themeInfo["ui_data"] {
            let naviBar = ui_data["navibar"]! as! [String:Any]
            let style = naviBar["status_style"]
            if style as! String == "Dark" {
                return .default
            }else{
                return .lightContent
            }
        }else{
            return .default
            
        }
    }
}
