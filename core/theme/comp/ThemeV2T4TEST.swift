//
//  ThemeV2T4.swift
//  magicapp
//
//  Created by WISA on 2018. 6. 25..
//  Copyright © 2018년 LeeDongChule. All rights reserved.
//

import UIKit

class ThemeV2T4TEST: CommonMkTheme {
    
    
    override func applayMain() {
        let view = self.viewController.view
        let mainController = self.viewController as? MainController
        if mainController == nil {
            return
        }

        print("dong account :", WInfo.accountId)
        
        let basic = uiData["basic"] as! [String:AnyObject]
        let extends = uiData["extends"] as! [String:AnyObject]
        
        let basic_menus = basic["menus"] as! [AnyObject]
        var extends_menus = extends["menus"] as! [AnyObject]
        var extends_enable_menus = [AnyObject]()
        
        let wisaExtendMenuHeight: CGFloat = 70.0;
        WInfo.naviHeight = 50;
        let wisaMenu:UIView = UIView(frame : CGRect(x: 0, y: view!.frame.height - CGFloat(truncating: WInfo.naviHeight) - Tools.safeArea(), width: UIScreen.main.bounds.width, height: CGFloat(truncating: WInfo.naviHeight)  + Tools.safeArea()) )
        let wisaExtendMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - (wisaExtendMenuHeight) - Tools.safeArea()-0.5,width: UIScreen.main.bounds.width, height: wisaExtendMenuHeight) )
        
        print("dong extend result before : ", extends_menus.count, extends_menus)
        
        for i in 0..<extends_menus.count {
            print("dong for ", extends_menus[i] );
            if (extends_menus[i]["enable"] as! Int) == 1 {
                extends_enable_menus.append(extends_menus[i])
            }
        }
        
        let themeCache: Bool = WInfo.extendIconCnt != extends_enable_menus.count ? false : true
        WInfo.extendIconCnt = extends_enable_menus.count;
        let basic_menu_width = UIScreen.main.bounds.width / CGFloat(basic_menus.count)
        let extends_menu_width = UIScreen.main.bounds.width / CGFloat(extends_enable_menus.count)
        let basic_bgColor = UIColor(hexString:basic["menusBg"] as! String)
        let extends_bgColor = UIColor(hexString:extends["menusBg"] as! String)
        
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = basic_bgColor
        wisaExtendMenu.isUserInteractionEnabled = true
        wisaExtendMenu.backgroundColor = extends_bgColor
        print("dong icon cache state", themeCache)
        var position = CGFloat(0)
        for menu in basic_menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: basic_menu_width ,height: wisaMenu.frame.height - Tools.safeArea()))
            let key = menu["click"] as! String
            let icon_url = menu["icon_url"] as! String
            
            menuView.extendThemeIconLoader(icon_url, cache: themeCache)

            menuView.showsTouchWhenHighlighted = true
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += basic_menu_width

            if key == "next" {
                mainController?.nextBtn = menuView
                menuView.isEnabled = false
            }
            if key == "prev" {
                mainController?.prevBtn = menuView
                menuView.isEnabled = false
            }

            if key == "push" {
                let newView = UIImageView()
                newView.themeIconLoaderN(menu["badge_url"] as! String)
                mainController?.isNewBadge = newView
                newView.frame = CGRect(x: 30,
                                       y: 13.166,
                                       width: 23.666,
                                       height: 23.666)
                newView.center.y = menuView.center.y
                menuView.addSubview(newView)
            }
            
            if key == "more" {
                let moreArrowView = UIView()
                moreArrowView.frame = CGRect(x: menuView.frame.size.width / 2 - 6, y: -0.5, width: 22, height: 16)
                let arrowView = UIImageView()
                let overlapArrowView = UIImageView()
                overlapArrowView.image = UIImage(named: "ic_a_extends_arrow.png")?.tintWithColor(UIColor(hexString:"#c7c7c7"))
                arrowView.image = UIImage(named: "ic_a_extends_arrow.png")?.tintWithColor(extends_bgColor)

                overlapArrowView.frame = CGRect(x: 0, y: 0, width: 12, height: 7)
                arrowView.frame = CGRect(x: 1, y: 0, width: 10, height: 6)
                
                moreArrowView.addSubview(overlapArrowView)
                moreArrowView.addSubview(arrowView)
                moreArrowView.alpha = 0.0
                moreArrowView.isHidden = true
                
                menuView.addSubview(moreArrowView)
                
            }
        }
        // extend menu
        position = CGFloat(0)
        print("dong size ", extends_menu_width, wisaExtendMenuHeight)
        for menu in extends_enable_menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: extends_menu_width ,height: wisaExtendMenu.frame.height))
            var page_url = ""
            if let check_url = menu["page_url"] as? String {
                page_url = check_url
            }
            
            let icon_url = menu["icon_url"] as? String
            menuView.themeIconLoader(icon_url!)
            menuView.showsTouchWhenHighlighted = true

            if ((menu["title"] as! String).isEmpty) != true  {
                let title_offset = CGFloat(6.5)
                let title_size = CGFloat(11)
                menuView.setTitle(menu["title"] as? String, for: .normal)
                menuView.setTitleColor(UIColor(hexString: extends["titleColor"] as! String), for: .normal)
                menuView.titleLabel?.font = UIFont.systemFont(ofSize: title_size)
                menuView.frame = menuView.frame.changeY(-title_offset)
                menuView.titleEdgeInsets = UIEdgeInsetsMake(wisaExtendMenu.frame.height / 1.5 + title_offset, 0, 0, 0);
            }
            
            self.applyAction(menuView, key: page_url)
            wisaExtendMenu.addSubview(menuView)
            position += extends_menu_width

        }
        
        let borderLayer = CALayer()
        let extendBorderLayer = CALayer()
        let defaultMenuHeight = view!.frame.height - CGFloat(truncating: WInfo.naviHeight) - Tools.safeArea()
        let border:UIView! = UIView(frame: CGRect(x: 0, y: defaultMenuHeight - 0.5, width: UIScreen.main.bounds.width, height: 0.5))
        border.backgroundColor = UIColor(hexString: "#c7c7c7")
        extendBorderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        
        extendBorderLayer.frame = CGRect(x: 0, y: 0, width: wisaMenu.frame.width, height: 0.5)
        
        wisaExtendMenu.layer.addSublayer(extendBorderLayer)
        view?.addSubview(wisaExtendMenu)
        view?.addSubview(border)
        view?.addSubview(wisaMenu)
        wisaExtendMenu.isHidden = true
       
        if let webBackground = uiData["webBackground"] as? String {
            mainController!.engine.webView.backgroundColor = UIColor(hexString:webBackground)
            mainController!.engine.webView.isOpaque = false
        }else {
            mainController!.engine.webView.backgroundColor = UIColor.white
            mainController!.engine.webView.isOpaque = false
        }
        
    }
    
    override func applyNavi() {
        
        let labelViewTag = 100
        let backTag = 101
        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
        let naviBar = ui_data["navibar"] as! [String:AnyObject]
        
        let topView = self.viewController.view.subviews[1]
        let titleView = topView.viewWithTag(labelViewTag) as! UILabel
        let back_button = topView.viewWithTag(backTag) as! UIButton
        let height = CGFloat( (naviBar["height"] as! NSNumber).floatValue )
        back_button.themeIconLoaderN(naviBar["icon_url"] as! String)
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
    
    override func applyAction(_ button: UIButton, key: String) {
        let main = self.viewController as? MainController
        button.onClick { (view) in
            main?.onExtendFunc(button, key)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let ui_data = WInfo.themeInfo["ui_data"] {
            let naviBar = ui_data["navibar"] as! [String:AnyObject]
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
