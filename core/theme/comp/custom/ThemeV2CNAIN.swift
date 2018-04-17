//
//  ThemeV2NAIN.swift
//  wing
//
//  Created by 이동철 on 2018. 3. 2..
//  Copyright © 2018년 JooDaeho. All rights reserved.
//

import UIKit

class ThemeV2CNAIN: CommonMkTheme {
    var mainController: MainController!
    var wisaMenu: UIView!
    let wisaMenuHeight: CGFloat = 100.0;
    var menuLayout1: UIView!
    var menuLayout2: UIView!
    var additionalLayout: Bool = false;
    var loginBtn: UIButton?
    var mypageBtn: UIButton?
    
    
    
    override func applayMain() {
        let view = self.viewController.view
        mainController = self.viewController as? MainController
        
        if mainController == nil {
            return
        }
        
        let menus = uiData["menus"] as! [String:AnyObject]
        
        let menusBg = uiData["menusBg"] as! [String: AnyObject]
        let top_menuBg = menusBg["top"] as! String
        let bottom_menuBg = menusBg["bottom"] as! String
        
        menuLayout1 = UIView(frame : CGRect(x: 0, y: view!.frame.height - wisaMenuHeight / 2 - Tools.safeArea(), width: UIScreen.main.bounds.width, height: wisaMenuHeight / 2) )
        menuLayout2 = UIView(frame : CGRect(x: 0, y: view!.frame.height - wisaMenuHeight - Tools.safeArea(), width: UIScreen.main.bounds.width, height: wisaMenuHeight / 2))

//        menuLayout1, menuLayout2 백그라운드 컬러도 매직앱 서버에서
        menuLayout1.isUserInteractionEnabled = true
        menuLayout2.isUserInteractionEnabled = true
        menuLayout1.backgroundColor = UIColor(hexString: bottom_menuBg)
        menuLayout2.backgroundColor = UIColor(hexString: top_menuBg)
        
        // bottom menus
        let bottom_menus = menus["bottom"] as! [[String:AnyObject]]
        var bottom_position = CGFloat(0)
        let menuWidth_bottom = UIScreen.main.bounds.width / CGFloat(menus["bottomNm"] as! CGFloat)
        
        for menu in bottom_menus {
            let key = menu["click"] as! String
            let menuView = UIButton.init(type: .custom)
            menuView.frame = CGRect(x: CGFloat(bottom_position), y: -5 , width: menuWidth_bottom ,height: wisaMenuHeight / 2)
            setButtonTitle(key : key, setButton: menuView)
            menuView.setTitleColor(UIColor(hexString: "#808080"), for: .normal)
            menuView.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)
            menuView.showsTouchWhenHighlighted = true
            menuView.titleEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0)
            menuView.contentVerticalAlignment = .center
            menuView.contentHorizontalAlignment = .center
            
            print("key : \(key) \n")
            self.applyAction(menuView, key: key)
            menuLayout1.addSubview(menuView)
            
            if key == "login" {
                loginBtn = menuView;
                checkWingLogin(key, menuView)
                continue
            }
            
            if key == "open" {
                continue
            }
            
            
            if key == "mypage" {
                mypageBtn = menuView;
                checkWingLogin(key, menuView)
                
            }
            
            if key == "setting" {
                menuView.isHidden = true
            }
            
            if key == "prev" {
                print("dong prev")
                mainController?.prevBtn = menuView
                menuView.isEnabled = false
            }
            
            if key == "next" {
                print("dong next")
                mainController?.nextBtn = menuView
                menuView.isEnabled = false
            }

            if key == "push" {
                let newView = UIImageView()
                newView.themeIconLoaderN(menu["badge_url"] as! String)
                mainController?.isNewBadge = newView
                newView.frame = CGRect(x: 33,
                                       y: 26.166,
                                       width: 23.666,
                                       height: 23.666)
                newView.center.y = menuView.center.y + 5
                menuView.addSubview(newView)
            }
            
            bottom_position += menuWidth_bottom
        }
        // top menus setting
        let top_menus = menus["top"] as! [[String:AnyObject]]
        var top_position = CGFloat(0)
        let menuWidth_top = UIScreen.main.bounds.width / CGFloat(menus["topNm"] as! CGFloat)
        for menu in top_menus {
            let key = menu["click"] as! String
            let menuView = UIButton(frame : CGRect(x: CGFloat(top_position), y: 0 , width: menuWidth_top ,height: wisaMenuHeight / 2))
            let icon_url = menu["icon_url"] as! String
            menuView.themeIconLoader(icon_url)
            menuView.showsTouchWhenHighlighted = true
            print("key : \(key) \n")
            self.applyAction(menuView, key: key)
            menuLayout2.addSubview(menuView)
            
            top_position += menuWidth_top
                            menuView.isEnabled = true
//            if key == "prev" {
//                print("dong prev")
//                mainController?.prevBtn = menuView
//                menuView.isEnabled = false
//            }
//
//            if key == "next" {
//                print("dong next")
//                mainController?.nextBtn = menuView
//                menuView.isEnabled = false
//            }
//
//            if key == "push" {
//                let newView = UIImageView()
//                newView.themeIconLoaderN(menu["badge_url"] as! String)
//                mainController?.isNewBadge = newView
//                newView.frame = CGRect(x: 30,
//                                       y: 13.166,
//                                       width: 23.666,
//                                       height: 23.666)
//                newView.center.y = menuView.center.y
//                menuView.addSubview(newView)
//            }
            
        }
        let borderLayer = CALayer()
        borderLayer.backgroundColor = UIColor(hexString:"#c7c7c7").cgColor
        borderLayer.frame = CGRect(x: 0, y: 1, width: UIScreen.main.bounds.width, height: Tools.toOriginPixel(1.0))

        menuLayout1.layer.addSublayer(borderLayer)
//        view?.addSubview(wisaMenu)
        menuLayout2.isHidden = true
        
        view?.addSubview(menuLayout2)
        view?.addSubview(menuLayout1)
        
        mainController!.engine.scrollView.contentInset.bottom = wisaMenuHeight / 2
        if Tools.safeArea() != 0 {
            let safeView = UIView(frame: CGRect(x: 0, y: view!.frame.height - Tools.safeArea(), width: UIScreen.main.bounds.width, height: Tools.safeArea()))
            safeView.backgroundColor = UIColor(hexString:bottom_menuBg)
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
    
        if key == "prev"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPrevClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "next"{
            button.addTarget(self.viewController , action: #selector(WMainController.onNextClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "reload"{
            button.addTarget(self.viewController , action: #selector(WMainController.onReloadClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "home"{
            button.addTarget(self.viewController , action: #selector(WMainController.onHomeClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "push"{
            button.addTarget(self.viewController , action: #selector(WMainController.onPushClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "open"{
            button.addTarget(self.viewController , action: #selector(WMainController.openLayout(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "close"{
            button.addTarget(self.viewController , action: #selector(WMainController.closeLayout(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "setting"{
            button.addTarget(self.viewController , action: #selector(WMainController.onSettingClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "login"{
            button.addTarget(self.viewController , action: #selector(WMainController.onLoginClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "mypage"{
            button.addTarget(self.viewController , action: #selector(WMainController.onMypageClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "latest_prd"{
            button.addTarget(self.viewController , action: #selector(WMainController.onLatestPrdClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "wish"{
            button.addTarget(self.viewController , action: #selector(WMainController.onWishClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "cart"{
            button.addTarget(self.viewController , action: #selector(WMainController.onCartClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "deliver"{
            button.addTarget(self.viewController , action: #selector(WMainController.onDeliverClick(_:)) , for: UIControlEvents.touchUpInside)
        }else if key == "location"{
            button.addTarget(self.viewController , action: #selector(WMainController.onLocationClick(_:)) , for: UIControlEvents.touchUpInside)
        }
        
    }
    
    
    
    // NAIN custom
//    // url 뒤에부분은 서버에서 json으로 내리기// NAIN custom
//    @objc func openLayout(_ sender: UIButton) {
//        let layout1 =  sender.superview! as UIView
//        let root = layout1.superview! as UIView
//        root.subviews[2].transform = CGAffineTransform(translationX: layout1.rsX, y: 100)
//        sender.isHidden = true
//        layout1.subviews[8].isHidden = false
//        root.subviews[2].isHidden = false
//
//        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.allowUserInteraction, .curveEaseInOut], animations: {
//
//            root.subviews[2].transform = CGAffineTransform(translationX: layout1.rsX, y: 0)
//        }) { (finish) in
//
//        }
//    }
//
//    @objc func closeLayout(_ sender: UIButton) {
//        let layout2 =  sender.superview! as UIView
//        let root = layout2.superview! as UIView
//        root.subviews[3].subviews[8].isHidden = true
//        root.subviews[3].subviews[7].isHidden = false
//
//        root.subviews[2].transform = CGAffineTransform(translationX: layout2.rsX, y: 0)
//        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.allowUserInteraction, .curveEaseInOut], animations: {
//            layout2.transform = CGAffineTransform(translationX: layout2.rsX, y: 100)
//        }) { (finish) in
//        }
//    }
//
//    // url 뒤에부분은 서버에서 json으로 내리기
//
//    @objc func onLoginClick(_ sender: UIButton) {
//        print("dong hahaha start")
//        let url = URL (string: "\(WInfo.appUrl)/member/login.php");
//        let requestObj = NSMutableURLRequest(url: url!);
////        self.en. engine.loadRequest(requestObj as URLRequest)
//        mainController.engine.loadRequest(requestObj as URLRequest)
//        print("dong hahaha end")
//
//    }
//    @objc func onMypageClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/mypage/mypage.php");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
//    @objc func onLatestPrdClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/shop/click_prd.php");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
//    @objc func onWishClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/mypage/wish_list.php");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
//    @objc func onCartClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/shop/cart.php");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
//    @objc func onDeliverClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/mypage/order_list.php");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
//    @objc func onLocationClick(_ sender: UIButton) {
//        let url = URL (string: "\(WInfo.appUrl)/board/?db=basic_1");
//        let requestObj = NSMutableURLRequest(url: url!);
//        mainController.engine.loadRequest(requestObj as URLRequest)
//    }
   
    func setButtonTitle(key:String, setButton button:UIButton) {
//        WMainController.scrollViewDidScroll(WMainController)
        if key == "prev" {
            button.setTitle("뒤로", for: .normal)
        } else if key == "next" {
            button.setTitle("앞으로", for: .normal)
        } else if key == "reload" {
            button.setTitle("새로고침", for: .normal)
        } else if key == "home" {
            button.setTitle("홈", for: .normal)
        } else if key == "push" {
            button.setTitle("알람", for: .normal)
        } else if key == "login" {
            button.setTitle("로그인", for: .normal)
        } else if key == "mypage" {
            button.setTitle("마이페이지", for: .normal)
        } else if key == "setting" {
            button.setTitle("설정", for: .normal)
        } else if key == "open" {
            button.setTitle("추가메뉴", for: .normal)
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
    
    func checkWingLogin(_ key: String, _ menuView: UIButton) {
        print("dong count !! : ", WInfo.userInfo.count)
        if WInfo.userInfo.count != 0 {
            if key == "login" {
                menuView.isHidden = true
            }
            if key == "mypage" {
                menuView.isHidden = false
            }
        } else {
            if key == "login" {
                menuView.isHidden = false
            }
            if key == "mypage" {
                menuView.isHidden = true
            }
        }
    }
}
