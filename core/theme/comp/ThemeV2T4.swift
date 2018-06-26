//
//  ThemeV2T4.swift
//  magicapp
//
//  Created by WISA on 2018. 6. 25..
//  Copyright © 2018년 LeeDongChule. All rights reserved.
//

import UIKit

class ThemeV2T4: CommonMkTheme {
    
    
    override func applayMain() {
        let view = self.viewController.view
        let mainController = self.viewController as? MainController
        if mainController == nil {
            return
        }
        // 확장
        WInfo.naviHeight = 80;
        
        let menus = uiData["menus"] as! [[String:AnyObject]]
        let extend_menus = uiData["extend_menus"] as! [[String:AnyObject]]
        let wisaExtendMenuHeight: CGFloat = 30.0;
        
        let wisaMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - CGFloat(truncating: WInfo.naviHeight) + wisaExtendMenuHeight - Tools.safeArea(),width: UIScreen.main.bounds.width, height: 50) )
        let wisaExtendMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - CGFloat(truncating: WInfo.naviHeight) - Tools.safeArea(),width: UIScreen.main.bounds.width, height: wisaExtendMenuHeight) )
        
        let menuWidth = UIScreen.main.bounds.width / CGFloat(menus.count)
        let extendMenuWidth = UIScreen.main.bounds.width / CGFloat(extend_menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
        print("dong uiData \(uiData)")
        let extendBgColor = UIColor(hexString:(uiData["extend_menusBg"] as! [String:Any])["color"] as! String)
        
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        wisaExtendMenu.isUserInteractionEnabled = true
        wisaExtendMenu.backgroundColor = extendBgColor
        
        var position = CGFloat(0)
        for menu in menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: menuWidth ,height: wisaMenu.frame.height))
            let key = menu["click"] as! String
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)
            
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
        }
        // extend menu
        position = CGFloat(0)
        for extend_menu in extend_menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: extendMenuWidth ,height: wisaExtendMenu.frame.height))
            let key = extend_menu["click"] as! String
            let page_url = extend_menu["page_url"] as! String
            
            menuView.showsTouchWhenHighlighted = true
//            let test = extend_menu["name"] as? String
//            menuView.setTitle(test, for: .normal)
            print("page url \(page_url) \(key)")
            menuView.setTitleColor(.white, for: .normal)
            menuView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            let rightBorderLayer = CALayer()
            rightBorderLayer.backgroundColor = UIColor(hexString:"#ffffff").cgColor
            rightBorderLayer.frame = CGRect(x: extendMenuWidth, y: wisaExtendMenuHeight / 3 , width: Tools.toOriginPixel(1.0), height: 10)
            menuView.layer.addSublayer(rightBorderLayer)
            
            if key == "extend1" {
                menuView.setTitle("마이페이지", for: .normal)
                self.applyAction(menuView, key: page_url)
            } else if key == "extend2" {
                menuView.setTitle("장바구니", for: .normal)
                self.applyAction(menuView, key: page_url)
            } else if key == "extend3" {
                menuView.setTitle("관심상품", for: .normal)
                self.applyAction(menuView, key: page_url)
            } else if key == "extend4" {
                menuView.setTitle("주문내역", for: .normal)
                self.applyAction(menuView, key: page_url)
            }
            
            
            menuView.titleLabel?.textAlignment = .right
            
            wisaExtendMenu.addSubview(menuView)
//            let wl = NSMutableString(string: "\\"+(extend_menu["name"] as! String))
//            let ss = CFStringTransform(wl, nil, "Any-Hex/Java" as NSString, true)
//
//            print("dong uiData333 \(wl as String)")
            
            position += extendMenuWidth
            
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
