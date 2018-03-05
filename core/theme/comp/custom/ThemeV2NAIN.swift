//
//  ThemeV2NAIN.swift
//  wing
//
//  Created by 이동철 on 2018. 3. 2..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeV2NAIN: CommonMkTheme {
    var wisaMenu: UIView!
    let wisaMenuHeight: CGFloat = 100.0;
    var menuLayout1: UIView!
    var menuLayout2: UIView!
    var additionalLayout: Bool = false;
    
    
    
    override func applayMain() {
        let view = self.viewController.view
        let mainController = self.viewController as? MainController
        
        if mainController == nil {
            return
        }
        
        wisaMenu = UIView(frame : CGRect(x: 0,y: view!.frame.height - wisaMenuHeight - Tools.safeArea(),width: UIScreen.main.bounds.width, height: wisaMenuHeight/2) )
        let menus = uiData["menus"] as! [[String:AnyObject]]
        
        menuLayout1 = UIView(frame : CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width, height: wisaMenuHeight / 2) )
        menuLayout2 = UIView(frame : CGRect(x: 0,y: wisaMenuHeight / 2, width: UIScreen.main.bounds.width, height: wisaMenuHeight / 2) )
        
        let menuWidth = UIScreen.main.bounds.width / CGFloat(menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
//        menuLayout1, menuLayout2 백그라운드 컬러도 매직앱 서버에서
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        menuLayout1.backgroundColor = bgColor
        menuLayout2.backgroundColor = bgColor
        wisaMenu.transform = CGAffineTransform(translationX: wisaMenu.rsX, y: wisaMenuHeight / 2)
        
        wisaMenu.addSubview(menuLayout1)
        wisaMenu.addSubview(menuLayout2)
        
        var position = CGFloat(0)
        for menu in menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: menuWidth ,height: wisaMenuHeight / 2))
            let key = menu["click"] as! String
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)
            menuView.showsTouchWhenHighlighted = true
            print("key : \(key)")
            self.applyAction(menuView, key: key)
            menuLayout1.addSubview(menuView)
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
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: wisaMenu.frame.width, height: Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
        menuLayout1.layer.addSublayer(borderLayer)
        menuLayout2.layer.addSublayer(borderLayer)
        view?.addSubview(wisaMenu)
        mainController!.engine.scrollView.contentInset.bottom = wisaMenu.frame.height
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
    
    override func applyAction(_ button: UIButton, key: String) {
        
        if key == "setting"{
            
                button.addTarget(self.viewController , action: #selector(WMainController.onLayout(_:)) , for: UIControlEvents.touchUpInside)
            
            
//                button.addTarget(self.viewController , action: #selector(WMainController.onLayoutHide(_:)) , for: UIControlEvents.touchUpInside)
            
            
        }
    }
    
    
    
    override func applyNavi() {
        
//        let labelViewTag = 100
//        let backTag = 101
//        let ui_data = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
//        let naviBar = ui_data["navibar"] as! [String:AnyObject]
//
//        let topView = self.viewController.view.subviews[1]
//        let titleView = topView.viewWithTag(labelViewTag) as! UILabel
//        let back_button = topView.viewWithTag(backTag) as! UIButton
//        let height = CGFloat( (naviBar["height"] as! NSNumber).floatValue )
//        back_button.themeIconLoaderN(naviBar["icon_url"] as! String)
//        topView.backgroundColor = UIColor(hexString:naviBar["bg"] as! String)
//        topView.frame = CGRect(x: 0, y: 0, width: topView.frame.width, height: CGFloat(height + UIApplication.shared.statusBarFrame.height))
//        topView.subviews[0].frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height , width: topView.frame.width, height : height)
//
//
//        let borderLayer = CALayer()
//        borderLayer.backgroundColor = UIColor(hexString: "#cbcbcb").cgColor
//        borderLayer.frame = CGRect(x: 0, y: topView.frame.height - 1.0 , width: topView.frame.width, height: Tools.toOriginPixel(1.0))
//        topView.layer.addSublayer(borderLayer)
//        titleView.font = UIFont.boldSystemFont(ofSize: CGFloat(naviBar["title_size"] as! Int ))
//        titleView.textColor = UIColor(hexString: naviBar["title_color"] as! String )
//
//        back_button.frame = CGRect(x: 0, y: 0, width: height,height: height)
        
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
