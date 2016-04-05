//
//  Controllers.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 24..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit


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

    override func applyTheme() throws{

    	let uiData = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
    	let menus = uiData["menus"] as! [[String:AnyObject]]
        let menuSize = CGFloat(uiData["menusSize"] as! Double * 1.2)
    	let wisaMenu:UIView = UIView(frame : CGRectMake(0,self.view.frame.height - menuSize,self.view.frame.width, menuSize) )
    	let menuWidth = self.view.frame.width / CGFloat(menus.count)
        wisaMenu.backgroundColor = UIColor(hexString:uiData["menusBg"] as! String)
        wisaMenu.userInteractionEnabled = true
    	var position = 0
    	for menu in menus {
    		let menuView = UIButton(frame : CGRectMake(CGFloat(position), 0 , menuWidth ,wisaMenu.frame.height))
            let key = menu["click"] as! String
            let menuIcon = UIImage(named : menuMap[key]!)!
            let xPosition = menuView.frame.width/2.0 - (menuIcon.size.width/2.0/2.0) + CGFloat(position)
            let yPosition = menuView.frame.height/2.0 - (menuIcon.size.width/2.0/2.0)
            let imageRect = CGRectMake(xPosition,yPosition,menuIcon.size.width/2.0,menuIcon.size.height/2.0)
            menuView.setImage(menuIcon, inFrame:imageRect, forState: .Normal)
            menuView.showsTouchWhenHighlighted = true
            menuView.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
            menuView.imageView?.center = menuView.center
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += Int(menuWidth)
    	}
        
    	self.view.addSubview(wisaMenu)
        self.webView.scrollView.contentInset.bottom = menuSize
        self.applyThemeFinish()
    }

}

class NotiController:WNotiController{
    
}

class SettingController:WSettingController{
    
}

