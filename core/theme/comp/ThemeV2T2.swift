//
//  ThemeV2T2.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeV2T2: CommonMkTheme {
    
    
    override func applayMain() {
        let view = self.viewController.view
        let mainController = self.viewController as? MainController
        if mainController == nil {
            return
        }
        WInfo.naviHeight = 50;
        let menus = uiData["menus"] as! [[String:AnyObject]]
        let wisaMenu:UIView = UIView(frame : CGRect(x: 0,y: view!.frame.height - 50 - Tools.safeArea(),width: UIScreen.main.bounds.width, height: 50) )
        let menuWidth = UIScreen.main.bounds.width / CGFloat(menus.count)
        let bgColor = UIColor(hexString:uiData["menusBg"] as! String)
        wisaMenu.isUserInteractionEnabled = true
        wisaMenu.backgroundColor = bgColor
        var position = CGFloat(0)
        for menu in menus {
            let menuView = UIButton(frame : CGRect(x: CGFloat(position), y: 0 , width: menuWidth ,height: wisaMenu.frame.height))
            let key = menu["click"] as! String
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)
//            menuView.hnk_setImageFromURL(NSURL(string: icon_url)!, forState: UIControlState.Normal, placeholder: UIImage(), success: { (image) in
//                let resize_img = image.makeFillImage(menuView)
//                menuView.setImage(nil, forState: UIControlState.Normal)
//                menuView.setBackgroundImage(resize_img, forState: UIControlState.Normal)
//                menuView.setBackgroundImage(resize_img, forState: UIControlState.Disabled)
//                
//                }, failure: { (error) in
//                    
//            })
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
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        borderLayer.frame = CGRect(x: 0, y: 0, width: wisaMenu.frame.width, height: Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
        view?.addSubview(wisaMenu)
//        mainController!.engine.scrollView.contentInset.bottom = wisaMenu.frame.height
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
