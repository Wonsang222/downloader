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
    
    override func webLoadedFinish(_ urlString: String?) {
        if self.engine.canGoBack {
            prevBtn?.isEnabled = true
        }else{
            prevBtn?.isEnabled = false
        }
        if self.engine.canGoForward {
            nextBtn?.isEnabled = true
        }else{
            nextBtn?.isEnabled = false
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIApplication.shared.applicationIconBadgeNumber == 0 {
            isNewBadge?.isHidden = true
        }else{
            isNewBadge?.isHidden = false
        }
    }

}

class NotiController:WNotiController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

class SettingController:WSettingController{
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo)?.applyNavi()
        let topView = self.view.subviews[1]
        let contentView = self.view.subviews[0]
        contentView.frame = CGRect(x: 0, y: topView.frame.height,
                                               width: self.view.frame.width,
                                               height: self.view.frame.height - topView.frame.height)
        

    }
}


extension BaseController{
    
  
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let theme = ThemeFactory.createTheme(self, themeInfo: WInfo.themeInfo) {
            return theme.preferredStatusBarStyle()
        }
        return .default
    }
    

}



