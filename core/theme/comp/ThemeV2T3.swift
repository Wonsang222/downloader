//
//  ThemeV2T2.swift
//  magicapp
//
//  Created by WISA on 2017. 2. 28..
//  Copyright © 2017년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeV2T3: CommonMkTheme {
    
    
    override func applayMain() {
        let mainController = self.viewController as? MainController
        if mainController == nil {
            return
        }
        if let webBackground = uiData["webBackground"] as? String {
            
            mainController!.engine.webView.backgroundColor = UIColor(hexString:webBackground)
            mainController!.engine.webView.isOpaque = false
        }else {
            mainController!.engine.webView.backgroundColor = UIColor.white
            mainController!.engine.webView.isOpaque = false
        }
        WInfo.naviHeight = 0;
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

