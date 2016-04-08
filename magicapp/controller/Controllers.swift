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
        let menuSize = CGFloat(uiData["menusSize"] as! Double)
    	let wisaMenu:UIView = UIView(frame : CGRectMake(0,self.view.frame.height - menuSize,self.view.frame.width, menuSize) )
    	let menuWidth = self.view.frame.width / CGFloat(menus.count)
        wisaMenu.backgroundColor = UIColor(hexString:uiData["menusBg"] as! String)
        wisaMenu.userInteractionEnabled = true
    	var position = 0
    	for menu in menus {
    		let menuView = UIButton(frame : CGRectMake(CGFloat(position), 0 , menuWidth ,wisaMenu.frame.height))
            let key = menu["click"] as! String
            let menuIcon = UIImage(named : menuMap[key]!)!
            let newMenuBg = menuIcon.makeFillImage(menuView)
            
            menuView.setBackgroundImage(newMenuBg, forState: .Normal)
            menuView.showsTouchWhenHighlighted = true
            self.applyAction(menuView, key: key)
            wisaMenu.addSubview(menuView)
            position += Int(menuWidth)
    	}
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor.blackColor().CGColor
        borderLayer.frame = CGRectMake(0, 0, CGRectGetWidth(wisaMenu.frame), Tools.toOriginPixel(1.0))
        wisaMenu.layer.addSublayer(borderLayer)
    	self.view.addSubview(wisaMenu)
        self.webView.scrollView.contentInset.bottom = menuSize
        self.applyThemeFinish()
    }

}

class NotiController:WNotiController{
    
}

class SettingController:WSettingController{
    
}





class TopNavigation:UIView{
    
    @IBOutlet private var contentView:UIView?
    @IBOutlet private var title:UILabel?
    @IBOutlet private weak var controller:UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commitInit()
    }
    
    private func commitInit(){
        NSBundle.mainBundle().loadNibNamed("TopNavigation", owner: self, options: nil)
        self.addSubview(contentView!)
    }
    
    override func awakeFromNib() {
        print(controller?.title!)
        self.title?.text = controller?.title!
    }
    
    @IBAction func doBack(sender:AnyObject){
        controller!.navigationController?.popViewControllerAnimated(true)
    }
}

