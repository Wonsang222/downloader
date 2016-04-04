//
//  Controllers.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 24..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import Foundation


class IntroController:WIntroController{
    
}

class MainController:WMainController{
    
    let menuMap = [
        "prev"      :"ic_a_prev",
        "next"      :"ic_a_next",
        "reload"    :"ic_a_refresh",
        "home"      :"ic_a_home",
        "share"     :"ic_a_share",
        "push"      :"ic_a_menu",
        "setting"   :"ic_a_tab"
    ]

    func applyTheme() throws{

    	let uiData = WInfo.themeInfo["ui_data"] as! [String:AnyObject]
    	let menus = uiData["menus"] as! [[String:AnyObject]]
    	let wisaMenu:UIView = UIView(frame : CGRectMake(0,0,self.view.frame.width,uiData["menusSize"] as! Double))
    	let menuWidth = self.view.frame.width / menus.count

        wisaMenu.backgroundColor = (uiData["menusBg"] as! String).toColor()
    	var position = 0
    	for menu in menus {
    		let menuView = UIButton(frame : CGRectMake(position, 0 , menuWidth ,wisaMenu.frame.height))
            position += 1
            menuView.image = UIImage(named : menuMap[menu["click"] as! String] as! String)
            self.applyAction(self,button: menuView,key: menuMap[menu["click"] as! String)
            wisaMenu.addSubView(menuView)
    	}
    	self.addSubView(wisaMenu)
    	self.applyThemeFinish()	
    }

}

class NotiController:WNotiController{
    
}

class SettingController:WSettingController{
    
}

