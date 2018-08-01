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
        // 확장
        WInfo.naviHeight = 80;
        print("dong account :", WInfo.accountId)
        
        let basic = uiData["basic"] as! [String:AnyObject]
        let extends = uiData["extends"] as! [String:AnyObject]
        
        let basic_menus = basic["menus"] as! [AnyObject]
        var extends_menus = extends["menus"] as! [AnyObject]
        
        let wisaExtendMenuHeight: CGFloat = 50.0;
        WInfo.naviHeight = 50;
        let wisaMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - CGFloat(truncating: WInfo.naviHeight),width: UIScreen.main.bounds.width, height: CGFloat(truncating: WInfo.naviHeight)) )
        let wisaExtendMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - (CGFloat(truncating: WInfo.naviHeight) + wisaExtendMenuHeight) - Tools.safeArea(),width: UIScreen.main.bounds.width, height: wisaExtendMenuHeight) )
        
        for i in 0..<extends_menus.count {
            print("dong for ", extends_menus[i]["enable"] as! Int );
            if (extends_menus[i]["enable"] as! Int) == 0 {
                extends_menus.remove(at: i)
            }
        }
//        print("dong extend result : ", extends_menus)
        
        let basic_menu_width = UIScreen.main.bounds.width / CGFloat(basic_menus.count)
        let extends_menu_width = UIScreen.main.bounds.width / CGFloat(extends_menus.count)
        let basic_bgColor = UIColor(hexString:basic["menusBg"] as! String)
        let extends_bgColor = UIColor(hexString:extends["menusBg"] as! String)
        
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = basic_bgColor
        wisaExtendMenu.isUserInteractionEnabled = true
        wisaExtendMenu.backgroundColor = extends_bgColor
        
        var position = CGFloat(0)
        for menu in basic_menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: basic_menu_width ,height: wisaMenu.frame.height))
            let key = menu["click"] as! String
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)

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
//                newView.themeIconLoaderN(menu["badge_url"] as! String)
                mainController?.isNewBadge = newView
                newView.frame = CGRect(x: 30,
                                       y: 13.166,
                                       width: 23.666,
                                       height: 23.666)
                newView.center.y = menuView.center.y
                menuView.addSubview(newView)
            }
        }
        // extend menu
        position = CGFloat(0)
        for menu in extends_menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: extends_menu_width ,height: wisaExtendMenu.frame.height))
            let key = menu["click"] as! String
            let page_url = menu["page_url"] as! String
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)

            menuView.showsTouchWhenHighlighted = true
//            let test = extend_menu["name"] as? String
            menuView.setTitle(menu["title"] as? String, for: .normal)
            menuView.setTitleColor(UIColor(hexString: extends["titleColor"] as! String), for: .normal)
            menuView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let rightBorderLayer = CALayer()
            rightBorderLayer.backgroundColor = UIColor(hexString:"#ffffff").cgColor
            rightBorderLayer.frame = CGRect(x: extends_menu_width, y: wisaExtendMenuHeight / 3 , width: Tools.toOriginPixel(1.0), height: 10)
            menuView.layer.addSublayer(rightBorderLayer)
//            self.applyAction(menuView, key: page_url)
//
//            if key == "extend1" {
//                menuView.setTitle("마이페이지", for: .normal)
//
//            } else if key == "extend2" {
//                menuView.setTitle("장바구니", for: .normal)
//                self.applyAction(menuView, key: page_url)
//            } else if key == "extend3" {
//                menuView.setTitle("관심상품", for: .normal)
//                self.applyAction(menuView, key: page_url)
//            } else if key == "extend4" {
//                menuView.setTitle("주문내역", for: .normal)
//                self.applyAction(menuView, key: page_url)
//            }


            menuView.titleLabel?.textAlignment = .right

            wisaExtendMenu.addSubview(menuView)
//            let wl = NSMutableString(string: "\\"+(extend_menu["name"] as! String))
//            let ss = CFStringTransform(wl, nil, "Any-Hex/Java" as NSString, true)
//
//            print("dong uiData333 \(wl as String)")

            position += extends_menu_width

        }
        
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: wisaMenu.frame.width, height: Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
        view?.addSubview(wisaMenu)
        view?.addSubview(wisaExtendMenu)

        if Tools.safeArea() != 0 {
            let safeView = UIView(frame: CGRect(x: 0, y: view!.frame.height - Tools.safeArea(), width: UIScreen.main.bounds.width, height: Tools.safeArea()))
            safeView.backgroundColor = UIColor(hexString:uiData["menusBg"] as! String)
            view?.addSubview(safeView)
        }
        
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
