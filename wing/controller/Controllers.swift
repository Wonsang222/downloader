//
//  Controllers.swift
//  magicapp
//
//  Created by JooDaeho on 2016. 3. 24..
//  Copyright © 2016년 JooDaeho. All rights reserved.
//

import UIKit
import WebKit

class IntroController:WIntroController{
    
}

class MainController:WMainController{
    
    var nextBtn:UIButton?
    var prevBtn:UIButton?
    var isNewBadge:UIImageView?
    
    
    override func applyTheme() throws{
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applayMain()
        self.beginController()
    }
    
    
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        if webView.canGoBack  {
            prevBtn?.enabled = true
        }else{
            prevBtn?.enabled = false
            
        }
        if webView.canGoForward {
            nextBtn?.enabled = true
            
        }else{
            nextBtn?.enabled = false
        }
    }
  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.sharedApplication().applicationIconBadgeNumber == 0 {
            isNewBadge?.hidden = true
        }else{
            isNewBadge?.hidden = false
        }
    }

}

class NotiController:WNotiController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
    }
    
}

class SettingController:WSettingController{
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        let topView = self.view.subviews[1]
        let contentView = self.view.subviews[0]
        contentView.frame = CGRectMake(0, CGRectGetHeight(topView.frame),
                                               CGRectGetWidth(self.view.frame),
                                               CGRectGetHeight(self.view.frame) - CGRectGetHeight(topView.frame))
        

    }
}


extension BaseController{
    
  
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let theme = ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo) {
            return theme.preferredStatusBarStyle()
        }
        return .Default
    }
    

}



