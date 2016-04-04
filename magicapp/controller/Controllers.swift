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
        let menuSize = CGFloat(uiData["menusSize"] as! Double * 1.5)
    	let wisaMenu:UIView = UIView(frame : CGRectMake(0,self.view.frame.height - menuSize,self.view.frame.width, menuSize) )
    	let menuWidth = self.view.frame.width / CGFloat(menus.count)
        wisaMenu.backgroundColor = UIColor(hexString:uiData["menusBg"] as! String)
    	var position = 0
    	for menu in menus {
    		let menuView = UIButton(frame : CGRectMake(CGFloat(position), 0 , menuWidth ,wisaMenu.frame.height))
            let key = menu["click"] as! String
            position += Int(menuWidth)
            print( menuView.imageView )
            menuView.setImage(UIImage(named : menuMap[key]!), forState: .Normal)
            self.applyAction(menuView, key: menuMap[key]!)
            wisaMenu.addSubview(menuView)
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

